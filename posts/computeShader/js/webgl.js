//Context
function glcontext(canvas) {
  //const gl = canvas.getContext("webgl2");
  const gl = canvas.getContext("webgl2", {
    premultipliedAlpha: false, // Ask for non-premultiplied alpha
  });
  gl || alert("You need a browser with webgl2. Try Firefox or Chrome.");

  gl.clearColor(0, 0, 0, 1);
  return gl;
}

//Program
function createProgram(gl, layout, common, text) {
  let verttext = common.concat("\n#define VERT;\n", text);
  let fragtext = common.concat("\n#define FRAG;\n", text);

  let vert = gl.createShader(gl.VERTEX_SHADER);
  gl.shaderSource(vert, verttext);
  gl.compileShader(vert);

  let frag = gl.createShader(gl.FRAGMENT_SHADER);
  gl.shaderSource(frag, fragtext);
  gl.compileShader(frag);

  let program = gl.createProgram();
  gl.attachShader(program, vert);
  gl.attachShader(program, frag);
  gl.linkProgram(program);

  const getAttributes = (gl, program, layout) => {
    let attributes = {};
    for (let name in layout) {
      let sz = layout[name];
      let loc = gl.getAttribLocation(program, name); //location if found. -1 otherwise.
      if (loc != -1) {
        attributes[name] = { loc, sz };
      }
    }
    return attributes;
  };

  const getUniforms = (gl, program, layout) => {
    let uniforms = {};
    for (let name in layout) {
      let func = layout[name];
      let loc = gl.getUniformLocation(program, name); //location if found, null otherwise
      if (loc != null) {
        uniforms[name] = { loc, func, isMatrix: func.includes("Matrix") };
      }
    }
    return uniforms;
  };

  //store attribute/uniform info (locations) in the program object.
  //Also:
  //put attribute size there for convenient "setAttributes"
  //put uniform function name for convenient "setUniforms"
  //Note:
  //Only uniforms/attributes that the shader actually uses (after compilation) will show up
  program.attributes = getAttributes(gl, program, layout.attributes);
  program.uniforms = getUniforms(gl, program, layout.uniforms);
  return program;
}

//Vertexarray
function vertexArray(gl, program, model) {
  const vao = gl.createVertexArray();
  gl.bindVertexArray(vao);
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(
    gl.ELEMENT_ARRAY_BUFFER,
    new Uint16Array(model.index),
    gl.STATIC_DRAW
  );
  for (let name in program.attributes) {
    if (name !== "index") {
      gl.enableVertexAttribArray(program.attributes[name].loc);
      gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
      gl.vertexAttribPointer(
        program.attributes[name].loc,
        program.attributes[name].sz,
        gl.FLOAT,
        false,
        0,
        0
      );
      gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array(model[name]),
        gl.STATIC_DRAW
      );
    }
  }
  gl.bindVertexArray(null);

  vao.mode = gl.TRIANGLES;
  vao.count = model.index.length;
  //vao.type = gl.UNSIGNED_INT; //if using "new Uint32Array(model.index)",
  vao.type = gl.UNSIGNED_SHORT;
  vao.offset = 0;
  return vao;
}

//Update/Draw
function clear(gl) {
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
}

function setUniforms(gl, program, uniforms) {
  //calling built-in gl functions to update uniform values.
  //Note: matrix functions have an extra transpose argument eg:
  //gl.uniform2fv(loc, [1,2]);
  //gl.uniformMatrix2x3fv(loc, false, [1,2,3,4,5,6]);
  //so just deal with it this way.. ("isMatrix" is set in getUniforms when program is created)
  for (let name in program.uniforms) {
    if (program.uniforms[name].isMatrix) {
      gl[program.uniforms[name].func](
        program.uniforms[name].loc,
        false,
        uniforms[name]
      );
    } else {
      gl[program.uniforms[name].func](
        program.uniforms[name].loc,
        uniforms[name]
      );
    }
  }
}

function setTextures(gl, textures) {
  for (let i = 0; i < textures.length; i++) {
    gl.activeTexture(gl.TEXTURE0 + i);
    gl.bindTexture(gl.TEXTURE_2D, textures[i]);
  }
}

function draw(gl, program, vao, uniforms, textures = []) {
  gl.useProgram(program);
  gl.bindVertexArray(vao); //aka setattributes(gl, program, model) but with pre-stored vao
  setUniforms(gl, program, uniforms);
  setTextures(gl, textures);
  gl.drawElements(vao.mode, vao.count, vao.type, vao.offset);
  gl.bindVertexArray(null);
}

function drawPoints(gl, program, uniforms, Npoints, textures = []) {
  //drawing without data
  //https://webgl2fundamentals.org/webgl/lessons/webgl-drawing-without-data.html
  //using gl_VertexID in the shader for the index of the point.
  //position the point in vertex shader
  gl.useProgram(program);
  setUniforms(gl, program, uniforms);
  setTextures(gl, textures);
  gl.drawArrays(gl.POINTS, 0, Npoints);
}

//Framebuffers
function setFrameBuffer(gl, fb, width = fb.width, height = fb.height) {
  //remember to pass canvas.width and canvas.height here fb.canvas because it will change
  gl.bindFramebuffer(gl.FRAMEBUFFER, fb.id);
  gl.viewport(0, 0, width, height);
  if (fb.drawbuffers) gl.drawBuffers(fb.drawbuffers);
}

function frameBuffer_canvas(canvas) {
  var fb = {};
  fb.id = null; //aka canvas
  fb.width = canvas.width;
  fb.height = canvas.height;
  fb.drawbuffers = null; //doesnt have a specific
  return fb;
}

function settexturefilters(gl, linearfilter) {
  if (linearfilter) {
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
  } else {
    //note: for a compute shader.. NEAREST gets the "correct" value (not blurred/interpolated)
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  }

  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
}

function randomRGBATextureData(width, height) {
  let N = width * height; //Number of pixels in texture
  //notes:
  //each pixel has 4 values if RGBA, first 4 values contains
  //rgba for first pixel (which is located at bottom left of texture)
  let data = new Uint8Array(4 * N);
  for (let i = 0; i < 4 * N; i++) {
    //data[i] = Math.random() * 255;
    data[i] = 100 + 2 * 27 * Math.random();
  }
  return data;
}

function frameBuffer(
  gl,
  width,
  height,
  options = { randomfill: false, linearfilter: true }
) {
  //id is a renderbuffer.
  //To access the "image" rendered into this buffer it needs to be "blitted" (with multisampling)
  //into another buffer (id2), which has a texture.
  //the texture can then be used in other shaders etc

  //so:
  //1. setFrameBuffer(id)
  //2. draw stuff
  //2. resolveFramebufferTexture(fb)
  //3. use the returned "texture" like you would any other rgba texture
  //4. optionally, use the returned "depthtexture" for depth information (keep in mind: its stored non-linearly)

  const Nsamples = gl.getParameter(gl.MAX_SAMPLES); //multisampled
  //const Nsamples = 0;

  //render to this buffer
  let colorbuffer = gl.createRenderbuffer();
  gl.bindRenderbuffer(gl.RENDERBUFFER, colorbuffer);
  gl.renderbufferStorageMultisample(
    gl.RENDERBUFFER,
    Nsamples,
    gl.RGBA8,
    width,
    height
  );

  let depthbuffer = gl.createRenderbuffer();
  gl.bindRenderbuffer(gl.RENDERBUFFER, depthbuffer);
  gl.renderbufferStorageMultisample(
    gl.RENDERBUFFER,
    Nsamples,
    gl.DEPTH_COMPONENT24,
    width,
    height
  );

  let id = gl.createFramebuffer();
  gl.bindFramebuffer(gl.FRAMEBUFFER, id);
  gl.framebufferRenderbuffer(
    gl.FRAMEBUFFER,
    gl.COLOR_ATTACHMENT0,
    gl.RENDERBUFFER,
    colorbuffer
  );
  gl.framebufferRenderbuffer(
    gl.FRAMEBUFFER,
    gl.DEPTH_ATTACHMENT,
    gl.RENDERBUFFER,
    depthbuffer
  );

  //resolve to this buffer which has color texture (and depth texture) attached
  let texture = gl.createTexture();
  gl.activeTexture(gl.TEXTURE0);
  gl.bindTexture(gl.TEXTURE_2D, texture);
  settexturefilters(gl, options.linearfilter);
  if (options.randomfill) {
    //gl.pixelStorei(gl.UNPACK_ALIGNMENT, 4);
    const data = randomRGBATextureData(width, height);
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      width,
      height,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      data
    );

    //console.log("filling...");
    //console.log("data: ", data);
    //gl.generateMipmap(gl.TEXTURE_2D);
  } else {
    gl.texImage2D(
      gl.TEXTURE_2D,
      0,
      gl.RGBA,
      width,
      height,
      0,
      gl.RGBA,
      gl.UNSIGNED_BYTE,
      null
    );
  }

  let depthtexture = gl.createTexture();
  gl.bindTexture(gl.TEXTURE_2D, depthtexture);
  settexturefilters(gl);
  gl.texImage2D(
    gl.TEXTURE_2D,
    0,
    gl.DEPTH_COMPONENT24,
    width,
    height,
    0,
    gl.DEPTH_COMPONENT,
    gl.UNSIGNED_INT,
    null
  );

  let id2 = gl.createFramebuffer();
  gl.bindFramebuffer(gl.FRAMEBUFFER, id2);
  gl.framebufferTexture2D(
    gl.FRAMEBUFFER,
    gl.COLOR_ATTACHMENT0,
    gl.TEXTURE_2D,
    texture,
    0
  );
  gl.framebufferTexture2D(
    gl.FRAMEBUFFER,
    gl.DEPTH_ATTACHMENT,
    gl.TEXTURE_2D,
    depthtexture,
    0
  );

  const fb = {
    id,
    id2,
    width,
    height,
    texture,
    depthtexture,
    drawbuffers: [gl.COLOR_ATTACHMENT0],
  };

  return fb;
}

function resolveFramebufferTexture(gl, fb) {
  gl.bindFramebuffer(gl.READ_FRAMEBUFFER, fb.id);
  gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, fb.id2);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  gl.blitFramebuffer(
    0,
    0,
    fb.width,
    fb.height,
    0,
    0,
    fb.width,
    fb.height,
    gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT,
    gl.NEAREST
  ); //LINEAR
}

function webgl() {
  canvas = document.getElementById("canvas");
  gl = canvas.getContext("webgl2");
  if (!gl) {return alert("need webgl2. try another browser");}

  gl.viewport(0, 0, canvas.width, canvas.height);
  //gl.enable(gl.DEPTH_TEST); gl.depthFunc(gl.LESS);
  gl.enable(gl.BLEND); gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  //gl.frontFace(gl.CW);
  //gl.enable(gl.CULL_FACE); gl.cullFace(gl.BACK);
  gl.enable(gl.DITHER);
  gl.clearColor(0, 0, 0, 1);
  return gl
}

function gldraw_instanced(program, vao, N, textures=[]) {
  gl.useProgram(program);
  settextures(textures)
  setuniforms(program)

  gl.bindVertexArray(vao);
  gl.drawElementsInstanced(vao.mode, vao.count, vao.type, vao.offset, N);
  gl.bindVertexArray(null);
}

function gldraw(program, vao, textures=[]) {
  gl.useProgram(program);
  settex3d(textures)
  setuniforms(program)
  gl.bindVertexArray(vao);
  gl.drawElements(vao.mode, vao.count, vao.type, vao.offset);
  gl.bindVertexArray(null);
}

function settextures(textures) {
  for (var i=0; i<textures.length; i++) {
    gl.activeTexture(gl.TEXTURE0+i);
    gl.bindTexture(gl.TEXTURE_2D, textures[i]);
  }
}

function settex3d(textures) {
  for (var i=0; i<textures.length; i++) {
    gl.activeTexture(gl.TEXTURE0+i);
    gl.bindTexture(gl.TEXTURE_3D, textures[i]);
  }
}

function setuniforms(program) {
  for (name in program.uniforms) {
    gl[program.uniforms[name].type](program.uniforms[name].location, uniforms[name]);
  }
}

function vertexarray(program, model) {
  var vao = gl.createVertexArray();
  gl.bindVertexArray(vao);
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, gl.createBuffer());
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint32Array(model.index), gl.STATIC_DRAW);
  for (name in program.attributes) {
    gl.enableVertexAttribArray(program.attributes[name].location);
    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer());
    gl.vertexAttribPointer(program.attributes[name].location, program.attributes[name].size, gl.FLOAT, false, 0, 0);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(model[name]), gl.STATIC_DRAW);
  }
  gl.bindVertexArray(null);
  vao.mode = gl.TRIANGLES;
  vao.count = model.index.length;
  vao.type = gl.UNSIGNED_INT;
  vao.offset = 0;
  return vao;
}

///////////////////////////////////////////////////////////////////////////////

async function fetchglsl() {
  var fns = ["common","sky"]
  var glsl = []
  for (var i=0; i<fns.length; i++) {
    var fn = "/glsl/" + fns[i] + ".glsl";
    glsl[i] = fetch(fn).then(res=>res.text())
  }
  return await Promise.all(glsl)
}

function shaderprograms(text) {
  ptr={}
  ptr.solzenazi = newf32pointer(2);
  ptr.coeffs = newf32pointer(3);
  ptr.cY = newf32pointer(5);
  ptr.cx = newf32pointer(5);
  ptr.cy = newf32pointer(5);

  uniforms = {};
  uniforms.cloudtex = 0;
  uniforms.solzenazi = new Float32Array(wasm.mem, ptr.solzenazi, 2);
  uniforms.coeffs = new Float32Array(wasm.mem, ptr.coeffs, 3);
  uniforms.cY = new Float32Array(wasm.mem, ptr.cY, 5);
  uniforms.cx = new Float32Array(wasm.mem, ptr.cx, 5);
  uniforms.cy = new Float32Array(wasm.mem, ptr.cy, 5);
  uniforms.ts=6.0; //time standard 0..24
  uniforms.turbidity = 5.0; //amount of particles in atmosphere (basically haziness)

  var layout={};
  layout.attributes = {
    "position": 3,
    "yoffset": 1,
    "clouds": 1,
    "rain": 1,
    //"temperature": 1,
  };

  layout.uniforms = {
    "cloudtex": "uniform1i",
    "solzenazi": "uniform2fv",
    "coeffs": "uniform3fv",
    "cY": "uniform1fv",
    "cx": "uniform1fv",
    "cy": "uniform1fv",
    "ts": "uniform1f",
    "turbidity": "uniform1f"
  };

  var shaders = {};
  shaders.sky = shaderprogram(gl, layout, text, 1);
  return shaders;  
}

///////////////////////////////////////////////////////////////////////////////

function shaderprogram(gl, layout, text, i) {
  var common = text[0];
  var VERT = "\n#define VERT;\n";
  var FRAG = "\n#define FRAG;\n";
  var verttext = common.concat(VERT,text[i]);
  var fragtext = common.concat(FRAG,text[i]);

  var vert = gl.createShader(gl.VERTEX_SHADER);
  gl.shaderSource(vert, verttext);
  gl.compileShader(vert);

  var frag = gl.createShader(gl.FRAGMENT_SHADER);
  gl.shaderSource(frag, fragtext);
  gl.compileShader(frag);

  var program = gl.createProgram();
  gl.attachShader(program, vert);
  gl.attachShader(program, frag);
  gl.bindAttribLocation(program, 0, "position");
  gl.linkProgram(program);

  program.attributes = getattributes(program, layout.attributes);
  program.uniforms = getuniforms(program, layout.uniforms);

  console.log("program",i, program);
  return program
}

function getattributes(program, layout) {
  var attributes = {};
  for (name in layout) {
    var id = gl.getAttribLocation(program, name);
    //console.log(id, name)
    if (id != -1) {
      attributes[name] = {};
      attributes[name].location = id;
      attributes[name].size = layout[name]; //value is number (size)
    }
  }
  return attributes
}

function getuniforms(program, layout) {
  var uniforms = {};
  for (name in layout) {
    var id = gl.getUniformLocation(program, name);
    //console.log(id, name)
    if (id != null) {
      uniforms[name] = {};
      uniforms[name].location = id;
      uniforms[name].type = layout[name]; //value is string (function name type)
    }
  }
  return uniforms
}

///////////////////////////////////////////////////////////////////////////////

function cube() {
  var model = {};
  model.position = [-1,-1,-1, 1,-1,-1, 1,1,-1, -1,1,-1,  -1,-1,1, 1,-1,1, 1,1,1, -1,1,1];
  model.index = [0,2,1,2,0,3,1,6,5,6,1,2,5,7,4,7,5,6,4,3,0,3,4,7,4,1,5,1,4,0,3,6,2,6,3,7];
  model.texcoord = [1,0, 0,0, 0,1, 1,1, 1,0, 0,0, 0,1, 1,1];
  return model;
}
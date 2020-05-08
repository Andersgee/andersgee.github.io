async function fetchglsl() {
  return await Promise.all([
    fetch("./glsl/pianokey.glsl").then(res=>res.text()),
    fetch("./glsl/pianobody.glsl").then(res=>res.text()),
  ])
}

//////////////////////////////////////////////////////////////////////////////
// webgl

function webgl(canvas) {
  gl = canvas.getContext("webgl") || canvas.getContext("experimental-webgl")
  if (!gl) {return alert("need webgl. try another browser")}  
  //vertexarray standard in webgl2, but also as extension in webgl
  var ext = gl.getExtension("OES_vertex_array_object") || gl.getExtension("MOZ_OES_vertex_array_object") || gl.getExtension("WEBKIT_OES_vertex_array_object")
  if (!ext) {return alert("couldnt get webgl extension vertex array object")}
  gl.createVertexArray = () => ext.createVertexArrayOES()
  gl.bindVertexArray = (vao) => ext.bindVertexArrayOES(vao)

  //gl = canvas.getContext("webgl2") //this instead of the above works on browsers that is not safari
  //if (!gl) {return alert("need webgl2. try another browser")}

  gl.viewport(0, 0, canvas.width, canvas.height)
  gl.enable(gl.BLEND)
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
  gl.enable(gl.DEPTH_TEST); gl.depthFunc(gl.LESS);
  gl.frontFace(gl.CW); //CCW standard
  gl.enable(gl.CULL_FACE); gl.cullFace(gl.BACK);
  //gl.enable(gl.DITHER)
  gl.clearColor(1, 1, 1, 1)

  return gl
}

function gldraw(program, vao) {
  gl.useProgram(program)
  setuniforms(program)
  gl.bindVertexArray(vao)
  gl.drawElements(vao.mode, vao.count, vao.type, vao.offset)
  gl.bindVertexArray(null)
}


//////////////////////////////////////////////////////////////////////////////
// shaders

function setuniforms(program) {
  for (const name in program.uniforms) {
    if (uniforms[name].length>4) {
      gl[program.uniforms[name].type](program.uniforms[name].location, false, uniforms[name]); //annoying extra transpose yes/no argument for matrices
    } else {
      gl[program.uniforms[name].type](program.uniforms[name].location,uniforms[name])
    }
  }
}

function vertexarray(program, model) {
  var vao = gl.createVertexArray()
  gl.bindVertexArray(vao)
  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, gl.createBuffer())
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(model.index), gl.STATIC_DRAW)
  for (const name in program.attributes) {
    gl.enableVertexAttribArray(program.attributes[name].location)
    gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer())
    gl.vertexAttribPointer(program.attributes[name].location, program.attributes[name].size, gl.FLOAT, false, 0, 0)
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(model[name]), gl.STATIC_DRAW)
  }
  gl.bindVertexArray(null)
  vao.mode = gl.TRIANGLES; //gl.POINTS
  vao.count = model.index.length
  //vao.type = gl.UNSIGNED_INT; //standard in webgl2, getExtension("OES_element_index_uint") needed in webgl1
  vao.type = gl.UNSIGNED_SHORT //max points 2^16=65535
  vao.offset = 0
  return vao
}

function shaderprograms(text) {
  var layout = {}
  layout.attributes = {
    pos: 3,
    texcoord: 2,
  }

  layout.uniforms = {
    proj: "uniformMatrix4fv", //projection matrix
    mv: "uniformMatrix4fv", //modelview matrix
    t: "uniform1f",
    key: "uniform1f",
    black: "uniform1f",
    xpos: "uniform1f",
    velocity: "uniform1f",
    mousexy: "uniform2fv",
    camera: "uniform3fv",
    focus: "uniform3fv",
  }

  uniforms = {}
  uniforms.proj = new Float32Array(16)
  uniforms.mv = new Float32Array(16)
  uniforms.t = 0.0
  uniforms.key = 0.0
  uniforms.black = 0.0
  uniforms.xpos = 0.0
  uniforms.velocity = 0.0
  uniforms.mousexy = [0.0, 0,0]
  uniforms.camera = [-40,20,0]
  uniforms.focus = [-40,0,0]

  var shaders = {}
  shaders.pianokey = shaderprogram(layout, text, 0)
  shaders.pianobody = shaderprogram(layout, text, 1)
  return shaders
}

function shaderprogram(layout, text, i) {
  var VERT = "#define VERT;\n"
  var FRAG = "#define FRAG;\n"
  var verttext = VERT.concat(text[i])
  var fragtext = FRAG.concat(text[i])

  var vert = gl.createShader(gl.VERTEX_SHADER)
  gl.shaderSource(vert, verttext)
  gl.compileShader(vert)

  var frag = gl.createShader(gl.FRAGMENT_SHADER)
  gl.shaderSource(frag, fragtext)
  gl.compileShader(frag)

  var program = gl.createProgram()
  gl.attachShader(program, vert)
  gl.attachShader(program, frag)
  gl.linkProgram(program)

  program.attributes = getattributes(program, layout.attributes)
  program.uniforms = getuniforms(program, layout.uniforms)

  console.log("program", i, program)
  return program
}

function getattributes(program, layout) {
  var attributes = {}
  for (const name in layout) {
    var id = gl.getAttribLocation(program, name)
    //console.log(id, name)
    if (id != -1) {
      attributes[name] = {}
      attributes[name].location = id
      attributes[name].size = layout[name] //value is number (size)
    }
  }
  return attributes
}

function getuniforms(program, layout) {
  var uniforms = {}
  for (const name in layout) {
    var id = gl.getUniformLocation(program, name)
    //console.log(id, name)
    if (id != null) {
      uniforms[name] = {}
      uniforms[name].location = id
      uniforms[name].type = layout[name] //value is string (function name type)
    }
  }
  return uniforms
}

function set_framebuffer() {
  var fb = {};
  fb.id = null; //canvas
  fb.fov = Math.PI/3;
  fb.near = 0.1;
  fb.far = 1000;
  fb.width = canvas.width;
  fb.height = canvas.height;

  gl.bindFramebuffer(gl.FRAMEBUFFER, fb.id);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  gl.viewport(0, 0, fb.width, fb.height);

  projection(uniforms.proj, fb.fov, fb.width/fb.height, fb.near, fb.far);
  modelview(uniforms.mv, uniforms.camera, uniforms.focus)
}

//////////////////////////////////////////////////////////////////////////////
// matrix stuff, unreadable in javascript ofc.

function projection(out, fovy, aspect, near, far) {
  //perspective projection
  var f = 1.0/Math.tan(0.5*fovy);
  var nf = 1/(near-far);
  out[0]=f/aspect; out[1]=0; out[2]=0; out[3]=0;
  out[4]=0; out[5]=f; out[6]=0; out[7]=0;
  out[8]=0; out[9]=0; out[10]=(far+near)*nf; out[11]=-1;
  out[12]=0; out[13]=0; out[14]=2*far*near*nf; out[15]=0;
  return out;
}


function modelview(out, eye, focus) {
  var up = [0,1,0];
  var x0 = void 0, x1 = void 0, x2 = void 0, y0 = void 0, y1 = void 0, y2 = void 0, z0 = void 0, z1 = void 0, z2 = void 0, len = void 0;
  var eyex = eye[0]; var eyey = eye[1]; var eyez = eye[2];
  var upx = up[0]; var upy = up[1]; var upz = up[2];
  var centerx = focus[0]; var centery = focus[1]; var centerz = focus[2];
  
  z0 = eyex - centerx; z1 = eyey - centery; z2 = eyez - centerz;
  len = 1 / Math.sqrt(z0 * z0 + z1 * z1 + z2 * z2);
  z0 *= len; z1 *= len; z2 *= len;
  x0 = upy*z2-upz*z1; x1 = upz*z0-upx*z2; x2 = upx*z1-upy*z0;
  len = Math.sqrt(x0 * x0 + x1 * x1 + x2 * x2);
  len = 1 / len; x0 *= len; x1 *= len; x2 *= len;

  y0 = z1*x2-z2*x1; y1 = z2*x0-z0*x2; y2 = z0*x1-z1*x0;
  len = Math.sqrt(y0 * y0 + y1 * y1 + y2 * y2);
  len =1/len; y0 *= len; y1 *= len; y2 *= len;

  out[0] = x0; out[1] = y0; out[2] = z0; out[3] = 0;
  out[4] = x1; out[5] = y1; out[6] = z1; out[7] = 0;
  out[8] = x2; out[9] = y2; out[10] = z2; out[11] = 0;
  out[12] = -(x0*eyex+x1*eyey+x2*eyez); out[13] = -(y0*eyex+y1*eyey+y2*eyez); out[14] = -(z0*eyex+z1*eyey+z2*eyez); out[15] = 1;
  return out;
}
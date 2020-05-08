#ifdef VERT
precision mediump float;
attribute vec3 pos;
uniform mat4 proj;
uniform mat4 mv;

void main() {
  vec3 offset = vec3(55.0, 0.0, 0.0)*1.05;
  vec3 scale = vec3(1.1, 1.0, 1.0);
  gl_Position = proj*mv*vec4(pos*scale-offset, 1.0);
}

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG
precision mediump float;

void main() {
  vec3 col = vec3(0.2235294117647059, 0.07450980392156863, 0.0392156862745098);
  gl_FragColor = vec4(col, 1.0);
}

#endif
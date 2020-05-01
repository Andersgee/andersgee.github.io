#ifdef VERT

in vec3 position;

void main() {
  vrain = (rain>0.0) ? 2.0 : 1.0;
  vposition = position;
  sundir = zenazi2vec(solzenazi.x, solzenazi.y);
  vec3 sunYxy = skycolor(0.99*solzenazi.x, solzenazi.y);
  sunY = clamp(sunYxy.x, 0.0, 1.0);
  sunY = (rain>0.0) ? sunY*2.5 : sunY;
  sunrgb = Yxy2rgb(sunYxy);

  vclouds = clouds - 0.2*smoothstep(0.25, 0.75, clouds); //hide sharpness at high coverage
  vclouds2 = 0.7*smoothstep(0.25, 1.0, clouds); //add base diffuse at high coverage
  //vclouds2 = vclouds2*smoothstep(0.0, 1.0, position.y);
  clipspace = vec4(position.x, 0.2*(position.y+yoffset), position.z, 1.0);
  gl_Position = clipspace;
}

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG

in vec3 vposition;

out vec4 fragcolor;

void main() {
  fragcolor = vec4(1.0, 0.0, 0.0, 1.0);
}

#endif

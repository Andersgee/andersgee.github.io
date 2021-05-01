#ifdef VERT

in vec2 clipspace;
in vec2 uv;

out vec2 texcoord;

void main() {
  texcoord = uv;
  gl_Position = vec4(clipspace, 0.0, 1.0);
}

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG

in vec2 texcoord;
uniform sampler2D texture0; // trails

out vec4 fragcolor;

void main() { fragcolor = texture(texture0, texcoord); }

#endif
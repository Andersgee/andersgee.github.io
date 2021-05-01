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
// uniform vec2 iResolution;
uniform sampler2D texture0; // points
uniform sampler2D texture1; // trails

out vec4 fragcolor;

void main() {
  float point = texture(texture0, texcoord).x;
  // float trail = texture(texture1, texcoord).x;
  vec2 c = gl_FragCoord.xy;
  // float trail = texelFetch(texture1, ivec2(c), 0).x;

  float t1 = texelFetch(texture1, ivec2(c) + ivec2(-1, 1), 0).x; // top row
  float t2 = texelFetch(texture1, ivec2(c) + ivec2(0, 1), 0).x;
  float t3 = texelFetch(texture1, ivec2(c) + ivec2(1, 1), 0).x;
  float t4 = texelFetch(texture1, ivec2(c) + ivec2(-1, 0), 0).x; // middle row
  float t5 = texelFetch(texture1, ivec2(c) + ivec2(0, 0), 0).x;
  float t6 = texelFetch(texture1, ivec2(c) + ivec2(1, 0), 0).x;
  float t7 = texelFetch(texture1, ivec2(c) + ivec2(-1, -1), 0).x; // bottom row
  float t8 = texelFetch(texture1, ivec2(c) + ivec2(0, -1), 0).x;
  float t9 = texelFetch(texture1, ivec2(c) + ivec2(1, -1), 0).x;

  float blurred = (t1 + t2 + t3 + t4 + t5 + t6 + t7 + t8 + t9) / 9.0;

  float intensity = clamp01(point / 9.0 + blurred);

  vec3 color = vec3(intensity * 0.95);

  fragcolor = vec4(color, 1.0);
}

#endif
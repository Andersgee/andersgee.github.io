#ifdef VERT

uniform sampler2D texture0; // agents
uniform int sqrtNagents;

vec4 fetchAgent(int id) {
  ivec2 texelcoord = ivec2(id % sqrtNagents, id / sqrtNagents);
  return texelFetch(texture0, texelcoord, 0);
}

// gl_VertexID:
// https://webgl2fundamentals.org/webgl/lessons/webgl-drawing-without-data.html

void main() {
  gl_PointSize = 16.0;
  vec4 agent = fetchAgent(gl_VertexID);
  vec2 pos = agent.xy * 2.0 - 1.0;
  gl_Position = vec4(pos, 0.0, 1.0);
}

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG

// uniform float iTime;
// uniform vec2 iResolution;

out vec4 fragcolor;

void main(void) { fragcolor = vec4(1.0, 0.0, 0.0, 1.0); }

#endif
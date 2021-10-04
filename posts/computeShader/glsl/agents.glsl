#ifdef VERT

in vec2 clipspace;

void main() { gl_Position = vec4(clipspace, 0.0, 1.0); }

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG

uniform sampler2D texture0; // agents
uniform sampler2D texture1; // trails

uniform float iTime;
uniform vec2 mousePos;
// uniform vec2 iResolution;

out vec4 newagent;

vec2 hash2(vec2 p) {
  vec2 k = vec2(0.3183099, 0.3678794);
  p = p * k + k.yx;
  return fract(16.0 * k * fract(p.x * p.y * (p.x + p.y)));
}

vec2 rotate(vec2 v, float a) {
  mat2 R = mat2(cos(a), sin(a), -sin(a), cos(a));
  return normalize(R * v);
}

void main(void) {
  vec4 agent = texelFetch(texture0, ivec2(gl_FragCoord.xy), 0);
  vec2 pos = agent.xy;
  vec2 dir = normalize(agent.zw * 2.0 - 1.0);
  float speed = 0.005;
  float sensedistance = speed * 0.96;
  float turnangle = 0.31;

  // sample 3 positions (of the trails) in front of the "ant
  vec2 dirL = rotate(dir, turnangle);
  vec2 dirR = rotate(dir, -turnangle);

  vec2 posL = pos + sensedistance * dirL;
  vec2 posF = pos + sensedistance * dir;
  vec2 posR = pos + sensedistance * dirR;

  float L = texture(texture1, posL).x;
  float F = texture(texture1, posF).x;
  float R = texture(texture1, posR).x;

  vec2 randdir = 0.5 * (hash2(pos + iTime) - 0.5);

  // turn based on the values of these trails
  vec2 newpos;
  vec2 newdir;
  if (L > F && L > R) {
    newdir = dirL; // + randdir * 0.5;
  } else if (R > F && R > L) {
    newdir = dirR; // + randdir * 0.5;
  } else {
    newdir = dir + randdir;
  }

  newpos = pos + speed * newdir;

  // reverse dir if newpos is outside edge
  // also add some random dir
  float rx = randdir.x * 2.0;
  float ry = randdir.y * 2.0;
  newdir.x = (newpos.x > 1.0 || newpos.x < 0.0) ? -newdir.x + rx : newdir.x;
  newdir.y = (newpos.y > 1.0 || newpos.y < 0.0) ? -newdir.y + ry : newdir.y;

  if (mousePos.x > 0.0) {
    // bias toward mouse when clicking/dragging on canvas
    vec2 biasdir = mousePos - newpos;
    newdir = normalize(newdir + 0.25 * biasdir) * 0.5 + 0.5;
  } else {
    newdir = normalize(newdir) * 0.5 + 0.5; // rescale to 0..1
  }

  newagent = vec4(clamp01(newpos), clamp01(newdir));
}

#endif
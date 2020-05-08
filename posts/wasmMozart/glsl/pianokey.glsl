#ifdef VERT
precision mediump float;
attribute vec3 pos;
uniform mat4 proj;
uniform mat4 mv;
uniform float key;
uniform float black;
uniform float xpos;
uniform float velocity;

varying vec3 p;
varying vec3 op;

mat3 dir2rotmat(vec3 b) {
  //https://math.stackexchange.com/questions/180418/calculate-rotation-matrix-to-align-vector-a-to-vector-b-in-3d/897677#897677
  mat3 eye = mat3(1.0);
  //mat3 eyeflip = mat3(1.0, 0.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0);
  if (b.y==1.0) {return eye;}
  //if (b.y==-1.0) {return eyeflip;}
      
  vec3 a = vec3(0.0, 1.0, 0.0);
  vec3 v = cross(a,b);
  mat3 S = mat3(0.0, v.z, -v.y, -v.z, 0.0, v.x, v.y, -v.x, 0.0);
  float k = (1.0-dot(a,b)) / dot(v,v);
  mat3 R = eye + S + S*S*k;
  return R;
}

void main() {
  op = pos; 
  float v = (velocity > 0.05) ? max(0.25, velocity) : 0.0;
  vec3 dir = normalize(vec3(0.0, 1.0, -0.08*velocity*(1.0+0.5*black)));
  vec3 rotatedpos = dir2rotmat(dir)*pos;
  vec3 offset = vec3(xpos, 0.0, 0.0);
  p = rotatedpos-offset;
  gl_Position = proj*mv*vec4(p, 1.0);
}

#endif

///////////////////////////////////////////////////////////////////////////////

#ifdef FRAG
precision mediump float;
varying vec3 p;
varying vec3 op;

uniform float key;
uniform float black;
uniform float xpos;
uniform vec3 camera;
uniform vec3 focus;

void main() {
  vec3 suncol = vec3(0.5);
  vec3 sundir = vec3(0.0, 1.0, 1.0);
  vec3 vnormal = vec3(0.0, 1.0, 0.0);
  float specexp = 30.0;

  vec3 V = normalize(camera-p);
  vec3 L = sundir;
  vec3 N = normalize(vnormal);
  vec3 H = normalize(V+L);

  //intensity of color
  float diffuse = max(0.0, dot(L,N));
  float specular = pow(max(0.0, dot(H,N)), specexp);

  float edgeness = (black>0.5) ? abs(op.x/0.31) : abs(2.0*(op.x-0.5)); //linear measure, 0 at center, 1 at edge of key
  edgeness = 1.0-0.75*smoothstep(0.75, 1.0, edgeness);
  vec3 col = vec3(1.0-black*0.95)*edgeness;

  float frontedgeness = -op.z/7.0;
  frontedgeness = 1.0-0.66*smoothstep(0.95, 1.0, frontedgeness);
  col *= frontedgeness;

  col = mix(col, suncol*(specular+diffuse), 0.5);
  gl_FragColor = vec4(col, 1.0);
}

#endif
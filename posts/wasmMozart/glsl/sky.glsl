#ifdef VERT

in vec3 position;
in float clouds;
in float rain;
in float yoffset;

uniform vec2 solzenazi;
uniform vec3 coeffs;
uniform float cY[5];
uniform float cx[5];
uniform float cy[5];

out float vclouds;
out float vclouds2;
out vec4 clipspace;
out vec3 vposition;
out vec3 sundir;
out float sunY;
out vec3 sunrgb;
out float vrain;

vec3 skycolor(float zenith, float azimuth) {
  float g = acos( sin(solzenazi.x)*sin(zenith)*cos(azimuth-solzenazi.y) + cos(solzenazi.x)*cos(zenith) );
  float zen = min(zenith, 0.5*PI);
  float Y = coeffs.x * perez(zen, g, cY);
  float x = coeffs.y * perez(zen, g, cx);
  float y = coeffs.z * perez(zen, g, cy);
  //return vec3(0.02*Y, x, y);
  return vec3(Y/40.0, x, y);
}

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

in float vclouds;
in float vclouds2;
in vec4 clipspace;
in vec3 vposition;
in vec3 sundir;
in float sunY;
in vec3 sunrgb;
in float vrain;

uniform vec2 solzenazi;
uniform vec3 coeffs;
uniform float cY[5];
uniform float cx[5];
uniform float cy[5];
uniform sampler3D cloudtex;
uniform float ts;

out vec4 fragcolor;

//float cc = 2.0;

vec3 skycolor(float zenith, float azimuth) {
  float g = acos( sin(solzenazi.x)*sin(zenith)*cos(azimuth-solzenazi.y) + cos(solzenazi.x)*cos(zenith) );
  float zen = min(zenith, 0.5*PI);
  float Y = coeffs.x * perez(zen, g, cY);
  float x = coeffs.y * perez(zen, g, cx);
  float y = coeffs.z * perez(zen, g, cy);
  //return vec3(0.02*Y, x, y);
  return vec3(Y/40.0, x, y);
}

float sampledensity(float cc, vec3 p, vec3 wind) {return cc+texture(cloudtex, 0.0003*p+wind).x;}


float sampledensity_light(float cc, vec3 p, vec3 p0, vec3 p1, vec3 p3, vec3 p5, vec3 p6, vec3 wind) {
  return sampledensity(cc, p+p0, wind) + sampledensity(cc, p+p1, wind) + sampledensity(cc, p+p3, wind) + sampledensity(cc, p+p5, wind) + sampledensity(cc, p+p6, wind);
}

vec4 cloudmarch(vec3 ro, vec3 rd, vec3 wind, vec3 sunrgb, float sunY, vec3 sundir, vec3 skyrgb, float vrain) {
  float cc = vclouds2*(0.25+0.75*smoothstep(-1.0, 0.5, vposition.y));
  float ss = 25.0;

  //some points in a cone for lightsamples
  mat3 R = dir2rotmat(sundir);
  vec3 p0 = 0.5*ss * sundir;
  vec3 p1 = 2.0*ss * R*vec3( 0.242535, 0.970142,  0.000000);
  vec3 p3 = 2.0*ss * R*vec3(-0.196215, 0.970142,  0.142558);
  vec3 p5 = 2.0*ss * R*vec3( 0.074947, 0.970142, -0.230665);
  vec3 p6 = 4.0*ss * sundir;

  //colors
  vec3 ambient = mix(skyrgb,sunrgb,sunY)/vrain;
  vec3 cloudcolor = skyrgb/vrain;

  //float clouddens = 0.0;
  float clouddens = vrain-1.0;
  float hg = HG(dot(sundir,rd), 0.5)*0.5; //phase

  vec3 p;
  float sampledens, lightdens, energy;

  for(float t=7.0*ss; t>0.0; t-=ss) {
    p = ro + t*rd;
    sampledens = vclouds*sampledensity(cc, p, wind);
    clouddens += sampledens;
    lightdens = vclouds*sampledensity_light(cc, p, p0, p1, p3, p5, p6, wind);
    energy = B(lightdens*cc)*P(sampledens)*hg;
    //Energy=B*P*HG (Schneider & Vos, 2015) https://www.guerrilla-games.com/read/the-real-time-volumetric-cloudscapes-of-horizon-zero-dawn
    cloudcolor = mix(ambient, cloudcolor+sunrgb*energy, sampledens);
  }
  float alpha = 1.0-B(clouddens);
  return vec4(cloudcolor, alpha);
}


float hash2(vec2 uv, float t) {
  //return fract(sin(uv.x + uv.y / 83532.14) * t * 403.9);
  return fract(sin(uv.x + uv.y / 8353.14) * t * 403.9);
}
/*

//hashes without sine here: https://www.shadertoy.com/view/4djSRW
float hash2(vec2 p, float t) {
  vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract(t*(p3.x + p3.y) * p3.z);
}
*/

void main() {
  float t = ts/24.0;

  float randoffset = texture(cloudtex, vec3(0.5)).x;
  float rainval = smoothstep(0.99,1.0,hash2(clipspace.xy, t+randoffset));
  rainval = (vrain>1.2) ? rainval : 0.0;
  float zenith = (-vposition.y*0.5+0.5) * PI/3.0 + PI/6.0; //fovy between pi/6 and pi/2 starting from straight up
  float azimuth = vposition.x * PI;
  vec3 skyYxy = skycolor(zenith, azimuth);
  vec3 skyrgb = Yxy2rgb(skyYxy);
  //vec3 skyrgb = Yxy2rgb(skycolor(zenith, azimuth));

  vec3 rd = zenazi2vec(zenith, azimuth);
  vec3 ro = clouddistance(rd)*rd;
  
  float k = 0.5*vposition.x;
  vec3 wind = 0.9*vec3(rd.x, 1.3*rd.y, rd.z)*t + vec3(k, 0.0, 0.0);

  vec3 p = 0.0004*ro;
  vec4 cloudrgba = cloudmarch(ro, rd, wind, sunrgb, sunY, sundir, skyrgb, vrain);

  
  cloudrgba.w -= 0.25*rainval;
  fragcolor = clamp(vec4(mix(skyrgb, cloudrgba.xyz, cloudrgba.w), 1.0), 0.0, 1.0);

  
  //fragcolor = vec4(raincolor, 1.0);
}

#endif

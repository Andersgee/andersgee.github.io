async function fetchassets() {
  //var u = "./posts/wasmMozart/"
  var u = "./"
  var assets = [webassembly(u), fetchmodels(u,params), fetchprimes(u), fetchnotes(u), fetchglsl()];
  return await Promise.all(assets);
}

function setup() {
  biasslider = document.getElementById("biasslider");

  startstop = document.getElementById('startstop');
  params = parampointers();
  audio = webaudio();

  canvas = document.getElementById("canvas");
  canvas.addEventListener("mousemove", (e) => {mousexy(e);});
  gl = webgl(canvas);

  fetchassets().then(assets=>{
    wasm = assets[0];
    models = assets[1];
    primedatas = assets[2];
    notes = assets[3];

    shaders = shaderprograms(assets[4]);
    vaos = pianokeys(shaders.pianokey);
    cube = body(shaders.pianobody);
    xpos = pianokeys_xpos()
    black = pianokeys_black()
    set_framebuffer()

    isplaying = false;
    arraysarelinked = false;
    startstop.innerHTML = "start";
    startstop.addEventListener('click', togglemusic);
  })
}

function togglemusic() {
  if (isplaying) {stopmusic(); startstop.innerHTML = "start";}
  else {primeandstartmusic();  startstop.innerHTML = "stop";}
  isplaying = !isplaying;
}

function primeandstartmusic() {
  if (!arraysarelinked) {createviews(); arraysarelinked=true;} //only needed once
  dataprime(primedatas, 12*60);
  selfprime(12*30);
  generatemusic = setInterval(selfgenerate, 84); // 12 steps per second
}

function stopmusic() {clearInterval(generatemusic);}

function mousexy(e) {uniforms.mousexy = [e.clientX/canvas.width, e.clientY/canvas.height]}

function selfgenerate() {
  step(); 
  playnotes(velocity);

  window.requestAnimationFrame(render);
}

function render() {
  let camdistance = (15 + uniforms.mousexy[1]*35)
  let a = 1.1*Math.sin(-2*(uniforms.mousexy[0]-0.5)) - 1.7
  uniforms.camera =[-30 + Math.cos(a)*camdistance, 20, Math.sin(a)*camdistance]
  uniforms.focus = [-30 + -15*(uniforms.mousexy[0]-0.5), 0, 0]

  modelview(uniforms.mv, uniforms.camera, uniforms.focus)
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

  gldraw(shaders.pianobody, cube)
  for (let i=0; i<96; i++) {
    uniforms.key = i;
    uniforms.xpos = xpos[i];
    uniforms.black = black[i];
    uniforms.velocity = velocity[i]
    gldraw(shaders.pianokey, vaos[i])
  }
  //window.requestAnimationFrame(render);
}

window.onload = setup()
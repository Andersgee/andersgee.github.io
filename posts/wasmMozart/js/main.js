async function fetchassets() {
  //var u = "./posts/wasmMozart/"
  var u = "./"
  var assets = [webassembly(u), fetchmodels(u,params), fetchprimes(u), fetchnotes(u)];
  return await Promise.all(assets);
}

function setup() {
  startstop = document.getElementById('startstop');
  params = parampointers();
  audio = webaudio();
  fetchassets().then(assets=>{
    wasm = assets[0];
    models = assets[1];
    primedatas = assets[2];
    notes = assets[3];

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

function selfgenerate() {step(); playnotes(velocity);}
function stopmusic() {clearInterval(generatemusic);}

window.onload = setup()

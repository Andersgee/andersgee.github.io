async function fetchassets() {
  var url = "./"
  var assets = [webassembly(url), fetchmodels(url,params), fetchprime(url), fetchtranslation(url)];
  return await Promise.all(assets);
}

function setup() {
  startstop = document.getElementById('startstop');
  shakespearetext = document.getElementById('shakespearetext');

  params = parampointers();

  fetchassets().then(assets=>{
    wasm = assets[0];
    models = assets[1];
    primedata = assets[2];
    translation = assets[3];

    arraysarelinked = false;
    startstop.innerHTML = "generate";
    startstop.addEventListener('click', do_stuff);
  })
}

function do_stuff() {
  shakespearetext.innerHTML = "doing stuff now";
  if (!arraysarelinked) {createviews(); arraysarelinked=true;} //only needed once
  dataprime(primedata, 2000);
  selfprime(2000);
  //console.log(translation.idx2char)
}

//function selfgenerate() {step(); playnotes(velocity);}

window.onload = setup()

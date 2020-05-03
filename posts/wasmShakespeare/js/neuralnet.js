function fprop(p, isbeta) {
  var bias=2.0;
  wasm.fprop(p.z,p.h,p.h2, p.W,p.b, p.Wz1,p.Uz1,p.bz1,p.Wr1,p.Ur1,p.br1,p.Wh1,p.Uh1,p.bh1, p.Wz2,p.Uz2,p.bz2,p.Wr2,p.Ur2,p.br2,p.Wh2,p.Uh2,p.bh2);
  
  if (isbeta) {
    wasm.mixture_m(p.m, p.z, p.Wm, p.bm, bias, 65*4, 65*4);
  } else {
    wasm.mixture_m(p.m, p.z, p.Wm, p.bm, bias, 65*4, 3*4);
  }
}

function fprop_and_sample() {
  fprop(params.alfa, false);
  fprop(params.beta1, true);
  fprop(params.beta2, true);
  fprop(params.beta3, true);

  ga = wsample(ma); //sampled model
  g = [wsample(m[0]), wsample(m[1]), wsample(m[2])];

  g_sampled = g[ga]
  //console.log(g)
  
  for (var i=0; i<65; i++) {g_picked[i] = 0.0;}
  g_picked[g_sampled] = 1.0;
}


function createviews() {
  storemodels(models, params)

  ma = f32view(params.alfa.m,3)
  m = [f32view(params.beta1.m, 65), f32view(params.beta2.m, 65), f32view(params.beta3.m, 65)]

  g_sampled = 0;
  g_picked = new Float32Array(65);
}

///////////////////////////////////////////////////////////////////////////////

function wsample(chances) {
    //var items=[0,1,2];
    var items=[...Array(chances.length).keys()]
    var sum = chances.reduce((acc, el) => acc + el, 0);
    var acc = 0;
    chances = chances.map(el => (acc = el + acc));
    var rand = Math.random() * sum;
    return items[chances.filter(el => el <= rand).length];
}

function usample(probs) {
  var r = new Float32Array(65);
  for (var i=0; i<65; i++) {
    if (probs[i]>(0.01+0.98*Math.random())) {
      r[i] = 1.0;
    } else {
      r[i] = 0.0;
    }
  }
  return r;
}

function shallowcopy(x) {return x.slice(0)}

function repeat(v, n) {
  var L=v.length;
  var b = new Array();
  for (var i=0; i<n*L; i++) {b.push(v[i%L]);}
  return b;
}

function circshift(v,n) {
  var a = v.slice(0);
  for (var i=0; i<n; i++) {a.unshift(a.pop());}
  return a;
}

function mulsum(v1, v2) {
  var s=0;
  for (var i=0; i<v1.length; i++) {s += v1[i]*v2[i];}
  return s;
}

function step() {
  fprop_and_sample()
  set_memory(0, g_picked); //input x
}



function selfprime(Nsteps) {
  var text = []
  var k = "ab"
  var newline_has_occured = false //dont start writing mid-sentence
  var lastk = "ab"
  for (var i=0; i<Nsteps; i++) {
    fprop_and_sample()
    set_memory(0, g_picked);
    
    k = translation.idx2char[g_sampled+1]
    if (k == "\n" && lastk == "\n") {
      newline_has_occured = true;
    }
    if (newline_has_occured) {
      if (k == "\n") {
        text.push("<br>")
      } else {
        text.push(String(translation.idx2char[g_sampled+1]))
      }  
    }
    
    lastk = k;
    //text.push(text.push(translation.idx2char[g_sampled+1])
  }
  
  shakespearetext.innerHTML = text.join("")
  console.log("priming on self for",Nsteps,"characters")
}



////////////////////////////////////////////////////////////////////

function randint(N) {return Math.floor(N*Math.random());} //randint(3) gives 0,1 or 2

async function fetchprime(url) {
  var folder = "models/prime/";
  var path = url+folder+"intchars.uint8array";
  return await fetch(path).then(res=>res.arrayBuffer()).then(buf=>new Uint8Array(buf));
}

async function fetchtranslation(url) {
  var folder = "models/prime/";
  var path = url+folder+"translation.json";
  return await fetch(path).then(res=>res.json());
}

function dataprime(primedata, Nsteps) {
  //console.log(primedata)
  var r = randint(primedata.length-Nsteps*2) //just some starting place not at the very end
  //var r = 0;
  var x = new Float32Array(65);
  for (var timestep=0; timestep<Nsteps; timestep++) {
    //x = new Float32Array(65);
    for (var i=0; i<65; i++) {x[i] = 0.0;}
    x[primedata[timestep+r]-1] = 1.0;
    //console.log(translation.idx2char[primedata[timestep+r]])

    set_memory(0, x); //input x
    fprop(params.alfa, false);
    fprop(params.beta1, true);
    fprop(params.beta2, true);
    fprop(params.beta3, true);
  }
  console.log("priming on text for",Nsteps,"characters")
}

////////////////////////////////////////////////////////////////////

async function fetchmodels(url,params) {
  var models=[
  fetchmodel(url,"models/alfa/", params.alfa),
  fetchmodel(url,"models/beta1/", params.beta1),
  fetchmodel(url,"models/beta2/", params.beta2),
  fetchmodel(url,"models/beta3/", params.beta3)
  ];
  return await Promise.all(models)
}

function storemodels(models,params) {
  storemodel(models[0], params.alfa)
  storemodel(models[1], params.beta1)
  storemodel(models[2], params.beta2)
  storemodel(models[3], params.beta3)
}

async function fetchmodel(url, folder,params) {
  model={}
  Object.keys(params).forEach(async function (param,i){
    if (internalparams.includes(param)) {return;} //internal params

    var path = url+folder+param+".float32array";
    model[param] = await fetch(path).then(res=>res.arrayBuffer()).then(buf=>{return new Float32Array(buf)});
  });
  //await object does not actually wait until resolved. might aswell just call store models after button click instead of writing some ugly boilerplate "await object" function
  return await model
}

function storemodel(model,params) {  
  for (param in params) {
    if (internalparams.includes(param)) {continue;} //internal params

    set_memory(params[param], model[param])
  }

  var zerovector = new Float32Array(65)
  set_memory(params.h, zerovector) //start with zero recurrent memories
  set_memory(params.h2, zerovector)
}

////////////////////////////////////////////////////////////////////

function parampointers() {
  //better name might be "memorymap"
  lastpointer=65*4 * 6; //leave some room for temp arrays at begining of memory, in this case 6
  internalparams = ["z","h","h2","m"];
  var params={}
  
  params.alfa = parampointer(false);
  params.beta1 = parampointer(true);
  params.beta2 = parampointer(true);
  params.beta3 = parampointer(true);
  
  console.log("needed wasm.memory:",lastpointer/1000000,"MB")
  console.log("needed wasm.memory pages:", Math.ceil(lastpointer/64000))
  return params;
}

function newptr(L) {
  var k = lastpointer;
  lastpointer += L*4;
  return k;
}

function parampointer(isbeta) {
  var s=65; //array size
  var s2=s*s; //matrix size

  var a = {}
  //internal params
  a.z = newptr(s); //output of fprop
  a.h = newptr(s); //memory layer1
  a.h2 = newptr(s); //memory layer2

  //inputtransform
  a.W = newptr(s2);
  a.b = newptr(s);

  //gru1
  a.Wr1 = newptr(s2);
  a.Ur1 = newptr(s2);
  a.br1 = newptr(s);

  a.Wz1 = newptr(s2);
  a.Uz1 = newptr(s2);
  a.bz1 = newptr(s);

  a.Wh1 = newptr(s2);
  a.Uh1 = newptr(s2);
  a.bh1 = newptr(s);

  //gru2
  a.Wr2 = newptr(s2);
  a.Ur2 = newptr(s2);
  a.br2 = newptr(s);

  a.Wz2 = newptr(s2);
  a.Uz2 = newptr(s2);
  a.bz2 = newptr(s);

  a.Wh2 = newptr(s2);
  a.Uh2 = newptr(s2);
  a.bh2 = newptr(s);

  //mixture_m
  if (isbeta) {
    a.m = newptr(65); //mixture_m output... mixture proportion (softmax(Wm*z+bm)) (often denoted as pi in statistics textbooks)
    a.Wm = newptr(s*65)
    a.bm = newptr(65);
  } else {
    a.m = newptr(3);
    a.Wm = newptr(s*3)
    a.bm = newptr(3);
  }

  return a;
}


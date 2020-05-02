function fprop(p, isbeta) {
  //var bias=1.5;
  var bias = biasslider.value
  wasm.fprop(p.z,p.h,p.h2, p.W,p.b, p.Wz1,p.Uz1,p.bz1,p.Wr1,p.Ur1,p.br1,p.Wh1,p.Uh1,p.bh1, p.Wz2,p.Uz2,p.bz2,p.Wr2,p.Ur2,p.br2,p.Wh2,p.Uh2,p.bh2);
  wasm.mixture_m(p.m, p.z, p.Wm, p.bm, bias, 96*4, 3*4);
  if (isbeta) {
    wasm.mixture_p(p.p1, p.z, p.Wp1, p.bp1, 96*4);
    wasm.mixture_p(p.p2, p.z, p.Wp2, p.bp2, 96*4);
    wasm.mixture_p(p.p3, p.z, p.Wp3, p.bp3, 96*4);
  }
}

function fprop_and_sample() {
  fprop(params.alfa, false);
  fprop(params.beta1, true);
  fprop(params.beta2, true);
  fprop(params.beta3, true);

  ga = wsample(ma); //sampled model
  g = [wsample(m[0]), wsample(m[1]), wsample(m[2])];

  p_sampled = allp[ga][g[ga]];
  p_picked = usample(p_sampled);
}


function createviews() {
  storemodels(models, params)

  ma = f32view(params.alfa.m,3)
  m = [f32view(params.beta1.m, 3), f32view(params.beta2.m, 3), f32view(params.beta3.m, 3)]
  m = [f32view(params.beta1.m, 3), f32view(params.beta2.m, 3), f32view(params.beta3.m, 3)]

  allp = [
  [f32view(params.beta1.p1, 96), f32view(params.beta1.p2, 96), f32view(params.beta1.p3, 96)],
  [f32view(params.beta2.p1, 96), f32view(params.beta2.p2, 96), f32view(params.beta2.p3, 96)],
  [f32view(params.beta3.p1, 96), f32view(params.beta3.p2, 96), f32view(params.beta3.p3, 96)]
  ]

  p_sampled = new Float32Array(96);
  p_picked = new Float32Array(96);
  velocity = new Float32Array(96);
}

///////////////////////////////////////////////////////////////////////////////

function wsample(chances) {
    var items=[0,1,2];
    var sum = chances.reduce((acc, el) => acc + el, 0);
    var acc = 0;
    chances = chances.map(el => (acc = el + acc));
    var rand = Math.random() * sum;
    return items[chances.filter(el => el <= rand).length];
}

function usample(probs) {
  var r = new Float32Array(96);
  for (var i=0; i<96; i++) {
    if (probs[i]>(0.01+0.98*Math.random())) {
      r[i] = 1.0;
    } else {
      r[i] = 0.0;
    }
  }
  return r;
}

function shallowcopy(x) {return x.slice(0)}

function allowednotes(root) {
  //this function disables a few intra chord notes, all other notes within chosen key are allowed.  
  var kp = shallowcopy(keypattern);
  var chord = chords[root%12];
  for (var i=0; i<chord.length; i++) {kp[root+i] = chord[i];}
  return kp
}

function keypatterns() {
  var pattern = repeat([1,0,1,0,1,1,0,1,0,1,0,1], 11)
  var patterns = new Array();
  for(var i=0; i<12; i++) {
    patterns.push(circshift(pattern,i));
  }
  return patterns;
}

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
  set_memory(0, p_picked); //input x
  
  //console.log("model:",ga, " component:",g[ga])
  //console.log(velocity)

  //do some crude modeling of how hands can move
  //basically, assume a hand can reach max 12 notes at the same time within 0.25 secs for righthand and 0.5 secs for lefthand

  //rolling high/low
  var lowestnote = p_picked.indexOf(1); 
  var highestnote = p_picked.lastIndexOf(1);
  //(indexOf will give -1 if "1" does not exist)
  if (lowestnote>0) {rollinglowest.shift(); rollinglowest.push(lowestnote);}
  if (highestnote>0) {rollinghighest.shift(); rollinghighest.push(highestnote);}

  var righthandlowest = Math.max(...rollinghighest)-12;
  var lefthandhighest = Math.min(...rollinglowest)+12;

  var generated_root = p_picked.indexOf(1); //p_picked.indexOf(1) gives index of first "1"

  var allowed = allowednotes(Math.max(0,generated_root)); 

  for (var j=0; j<96; j++) {
    if ((generated_root>=0) && (j>=righthandlowest || j<=lefthandhighest)) {
    //if (j>=righthandlowest || j<=lefthandhighest) {
      p_picked[j] = p_picked[j]*allowed[j];
    } else {
      p_picked[j] = 0;
    }
  }
  //set_memory(0, p_picked); //recur filtered allowed(picked) instead of picked?
  
  for (var i=0; i<96; i++) {velocity[i] = p_picked[i]*Math.max(0.3, p_sampled[i]);}
}



function selfprime(Nsteps) {
  var keysum=[0,0,0,0,0,0,0,0,0,0,0,0];
  var patterns = keypatterns()
  for (var i=0; i<Nsteps; i++) {
    fprop_and_sample()
    set_memory(0, p_picked);

    for (var k=0; k<12; k++) {keysum[k] += mulsum(p_sampled, patterns[k])}
  }

  console.log("priming on self for",Nsteps/12,"seconds")
  var bestkey = keysum.indexOf(Math.max(...keysum));

  //limit future based on selfpriming:
  keypattern = patterns[bestkey]

  //also disable a few intra notes based on generated root
  var Major = [1,0,0,0,1,0,0,1];
  var minor = [1,0,0,1,0,0,0,1];
  var dim = [1,0,0,1,0,0,1,0];
  //var outofkey =[1,0,0,0,0,0,0,0];
  var outofkey = [0];
  var A=[Major, outofkey, minor, outofkey, minor, Major, outofkey, Major, outofkey, minor, outofkey, dim]
  chords = circshift(A, bestkey)

  rollinglowest=[36,36,36,36,36,36];
  rollinghighest=[60,60,60];
}



////////////////////////////////////////////////////////////////////

function randint(N) {return Math.floor(N*Math.random());} //randint(3) gives 0,1 or 2

async function fetchprimes(url) {
  var folder = "models/prime/";
  primenames=["mz_311_1","mz_311_2","mz_311_3","mz_330_1","mz_330_2","mz_330_3","mz_331_1","mz_331_2","mz_331_3","mz_332_1","mz_332_2","mz_332_3","mz_333_1","mz_333_2","mz_333_3","mz_545_1","mz_545_2","mz_545_3","mz_570_1","mz_570_2","mz_570_3"];
  var primedatas=[];
  for (var i=0; i<primenames.length; i++) {
    var path = url+folder+primenames[i]+".uint8array";
    primedatas[i] = fetchprime(path);
  }
  return await Promise.all(primedatas);
}

async function fetchprime(path) {
  var primedata = await fetch(path).then(res=>res.arrayBuffer()).then(buf=>new Uint8Array(buf));
  return primedata;
}

function readtimestep(i, primedata) {
  // note to self: 
  // I stored primedata in this format which has mostly zeros in it but allows for easy parsing and lightweight uint8
  // [NRnotes,note1,note2, NRnotes,note1, NRnotes, NRnotes, NRnotes,note1]
  // [      2,   68,   69,       1,   54,       0,       0,       1,   67]
  var x = new Float32Array(96);
  var nrnotes=primedata[i]
  i+=1; //modify
  for (var j=0; j<nrnotes; j++) {
    x[primedata[i]]=1;
    i+=1;
  }
  return [i,x]
}

function dataprime(primedatas, Nsteps) {
  var randsong = randint(21);
  var primedata = primedatas[randsong];
  console.log("priming on",primenames[randsong],"for",Nsteps/12,"seconds")
  var i=0; //index of primedata
  var x = new Float32Array(96);
  for (var timestep=0; timestep<Nsteps; timestep++) {
    [i,x] = readtimestep(i, primedata)

    set_memory(0, x); //input x
    fprop(params.alfa, false);
    fprop(params.beta1, true);
    fprop(params.beta2, true);
    fprop(params.beta3, true);
  }
}

////////////////////////////////////////////////////////////////////

async function fetchmodels(url, params) {
  var models=[
  fetchmodel(url+"models/alfa/", params.alfa),
  fetchmodel(url+"models/beta1/", params.beta1),
  fetchmodel(url+"models/beta2/", params.beta2),
  fetchmodel(url+"models/beta3/", params.beta3)
  ];
  return await Promise.all(models)
}

function storemodels(models,params) {
  storemodel(models[0], params.alfa)
  storemodel(models[1], params.beta1)
  storemodel(models[2], params.beta2)
  storemodel(models[3], params.beta3)
}

async function fetchmodel(folder,params) {
  model={}
  Object.keys(params).forEach(async function (param,i){
    if (internalparams.includes(param)) {return;} //internal params

    var path = folder+param+".float32array";
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
}

////////////////////////////////////////////////////////////////////

function parampointers() {
  //better name might be "memorymap"
  lastpointer=96*4 * 6; //leave some room for temp arrays at begining of memory, in this case 6
  internalparams = ["z","h","h2","m","p1","p2","p3"];
  var params={}
  
  params.alfa = parampointer(false);
  params.beta1 = parampointer(true);
  params.beta2 = parampointer(true);
  params.beta3 = parampointer(true);
  
  console.log("needed wasm.memory:",lastpointer/1000000,"MB")
  //console.log("needed wasm.memory pages:", Math.ceil(lastpointer/64000))
  return params;
}

function newptr(L) {
  var k = lastpointer;
  lastpointer += L*4;
  return k;
}

function parampointer(isbeta) {
  var s=96; //array size
  var s2=s*s; //matrix size

  var a = {}
  //internal params
  a.z = newptr(s); //output of fprop
  a.h = newptr(s); //memory layer1
  a.h2 = newptr(s); //memory layer2
  a.m = newptr(3); //mixture_m output... mixture proportion (softmax(Wm*z+bm)) (often denoted as pi in statistics textbooks)

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
  a.Wm = newptr(s*3)
  a.bm = newptr(3);

  //mixture_p
  if (isbeta) {
    a.p1 = newptr(s); //mixture_p output...  component1 output probability (sigm(Wp*z+bp))
    a.p2 = newptr(s); //component2
    a.p3 = newptr(s); //component3

    a.Wp1 = newptr(s2);
    a.bp1 = newptr(s);

    a.Wp2 = newptr(s2);
    a.bp2 = newptr(s);

    a.Wp3 = newptr(s2);
    a.bp3 = newptr(s);
  }

  return a;
}


async function webassembly(url) {
  var memory = new WebAssembly.Memory({initial:37, maximum:37});

  var imports = {
    mem: memory,
    consolelog: x => console.log(x),
    exp: x => {return Math.exp(x)},
    tanh: x => {return Math.tanh(x)},
  }

  var fn = url+"wasm/HRMDN.wasm"
  var {instance} = await WebAssembly.instantiateStreaming(fetch(fn), {imports});

  var wasm = {};
  wasm.debugfunc = instance.exports.debugfunc;
  wasm.fprop = instance.exports.fprop;
  wasm.mixture_m = instance.exports.mixture_m;
  wasm.mixture_p = instance.exports.mixture_p;
  wasm.mix = instance.exports.mix; //y = a*(1-t) + b*t (py, pa, pb, t, L)   ptr.press = 1536
  wasm.mem = memory.buffer; //ArrayBuffer
  wasm.memory = new Float32Array(memory.buffer);

  return wasm;
}

//get and set using bytepointers
function get_memory(ptr, vec) {for (var i=0; i<vec.length; i++) {vec[i] = wasm.memory[ptr/4+i];}}
function set_memory(ptr, vec) {for (var i=0; i<vec.length; i++) {wasm.memory[ptr/4+i] = vec[i];}}

function f32view(ptr, L) {
  return new Float32Array(wasm.mem, ptr, L)
}
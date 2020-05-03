async function webassembly(url) {
  var memory = new WebAssembly.Memory({initial:16, maximum:16});

  var imports = {
    mem: memory,
    consolelog: x => console.log(x),
    exp: x => {return Math.exp(x)},
    tanh: x => {return Math.tanh(x)},
  }

  var path = url+"wasm/HRMDN.wasm"
  var {instance} = await WebAssembly.instantiateStreaming(fetch(path), {imports});

  var wasm = {};
  wasm.debugfunc = instance.exports.debugfunc;
  wasm.fprop = instance.exports.fprop;
  wasm.mixture_m = instance.exports.mixture_m;
  wasm.mixture_p = instance.exports.mixture_p;
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

function print_memory(ptr, L) {
  var vec = new Float32Array(L)
  for (var i=0; i<L; i++) {vec[i] = wasm.memory[ptr/4+i];}
  console.log("ptr",ptr," vec",vec)
}
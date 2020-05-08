function repeat(v, N) {
  //repeat v, N times, but add a to elements each iteration
  var vs = v.slice(0);
  for (var i=1; i<N; i++) {
    for (var j=0; j<v.length; j++) {
      vs.push(v[j])
    }
  }
  return vs
}

function repeat_offset(v, N, a) {
  //repeat v, N times, but add a to elements each iteration
  var vs = v.slice(0);
  for (var i=1; i<N; i++) {
    for (var j=0; j<v.length; j++) {
      vs.push(v[j]+a*i)
    }
  }
  return vs
}

function pianokeys_black() {return repeat([0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0], 8)}
function pianokeys_xpos() {return repeat_offset([0, 0, 1, 1, 2, 3, 3, 4, 4, 5, 5, 6], 8, 7)}

function pianokeys(shader) {
  var w1 = vertexarray(shader, mw1());
  var w2 = vertexarray(shader, mw2());
  var w3 = vertexarray(shader, mw3());
  var b = vertexarray(shader, mb1());
  var vaos = repeat([w1,b,w2,b,w3,w1,b,w2,b,w2,b,w3], 8)
  return vaos;
}

function cube(shader) {
  var model = {};
  model.pos = [-1,-1,-1, 1,-1,-1, 1,1,-1, -1,1,-1,  -1,-1,1, 1,-1,1, 1,1,1, -1,1,1];
  model.index = [0,1,2,2,3,0,1,5,6,6,2,1,5,4,7,7,6,5,4,0,3,3,7,4,4,5,1,1,0,4,3,2,6,6,7,3];
  model.texcoord = [0,0, 1,0, 1,1, 0,1, 0,0, 1,0, 1,1, 0,1];
  return vertexarray(shader, model);
}


function body(shader) {
  var model = {};
  var notestandheight = 8
  model.pos = [0,-4,-8, 56,-4,-8, 0,0,-8, 56,0,-8, 0,0,0, 56,0,0, 0,notestandheight,4, 56,notestandheight,4]
  model.index = [0,1,3, 0,3,2, 2,3,5, 2,5,4, 4,5,7, 4,7,6]
  return vertexarray(shader, model);
}

function mw1() {
  var model = {};
  model.pos =   [0,1,-7, 0,1,-7, 1,1,-7, 0,1,-4.5, 0.31,1,-4.5, 1,1,-4.5, 0.31,1,0, 1,1,0, 0,0,-7, 0,0,-7, 1,0,-7, 0,0,-4.5, 0.31,0,-4.5, 1,0,-4.5,0.31, 0,0,1, 0,0,]
  model.index = [0,1,4,0,4,3,1,2,5,1,5,4,4,5,7,4,7,6,8,9,1,8,1,0,9,10,2,9,2,1,10,13,5,10,5,2,13,15,7,13,7,5,15,14,6,15,6,7,14,12,4,14,4,6,12,11,3,12,3,4,11,8,0,11,0,3,9,12,9,8,11,12,9,13,10,9,12,13,12,15,13,12,14,15]
  return model
}

function mw2() {
  var model = {};
  model.pos = [0.31, 1, -7,0.69, 1, -7,1, 1, -7,0.31, 1, -4.5,0.69, 1, -4.5,1, 1, -4.5,0.31, 1, 0,0.69, 1, 0,0.31, 0, -7,0.69, 0, -7,1, 0, -7,0.31, 0, -4.5,0.69, 0, -4.5,1, 0, -4.5,0.31, 0, 0,0.69, 0, 0,0, 1, -7,0, 1, -4.5,0, 0, -7,0, 0, -4.5,]
  model.index = [0,1,4,0,4,3,1,2,5,1,5,4,3,4,7,3,7,6,8,9,1,8,1,0,9,10,2,9,2,1,10,13,5,10,5,2,13,12,4,13,4,5,12,15,7,12,7,4,15,14,6,15,6,7,14,11,3,14,3,6,11,8,0,11,0,3,8,12,9,8,11,12,9,13,10,9,12,13,11,15,12,11,14,15,16,0,3,16,3,17,18,8,0,18,0,16,11,19,17,11,17,3,19,18,16,19,16,17, 18,11,8, 18,19,11]
  return model
}

function mw3() {
  var model = {};
  model.pos = [0, 1, -7,0.69, 1, -7,1, 1, -7,0, 1, -4.5,0.69, 1, -4.5,1, 1, -4.5,0, 1, 0,0.69, 1, 0,0, 0, -7,0.69, 0, -7,1, 0, -7,0, 0, -4.5,0.69, 0, -4.5,1, 0, -4.5,0, 0, 0,0.69, 0, 0,]
  model.index = [0,1,4,0,4,3,1,2,5,1,5,4,3,4,7,3,7,6,8,9,1,8,1,0,9,10,2,9,2,1,10,13,5,10,5,2,13,12,4,13,4,5,12,15,7,12,7,4,15,14,6,15,6,7,14,11,3,14,3,6,11,8,0,11,0,3,8,12,9,8,11,12,9,13,10,9,12,13,11,15,12,11,14,15]
  return model
}

function mb1() {
  //black note shape
  var model = {}; 
  var frontslope = 0.15
  var sideslope = 0.1
  var height = 0.5 //above white notes
  model.pos=[-(0.31-sideslope), 1+height, -4.5+frontslope, 0.31-sideslope, 1+height, -4.5+frontslope,0.31-sideslope, 1+height, 0,-(0.31-sideslope), 1+height, 0,-0.31, 1, -4.5, 0.31, 1, -4.5, 0.31, 1, 0, -0.31, 1, 0, -0.31, 0, -4.5, 0.31, 0, -4.5, 0.31, 0, 0, -0.31, 0, 0,]
  model.index = [0,1,2,0,2,3,4,5,1,4,1,0,5,6,2,5,2,1,6,7,3,6,3,2,7,4,0,7,0,3,8,9,5,8,5,4,9,10,6,9,6,5,10,11,7,10,7,6,11,8,4,11,4,7,8,10,9,8,11,10]
  return model
}

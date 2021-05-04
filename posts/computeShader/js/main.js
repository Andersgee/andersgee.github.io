async function fetchglsl() {
  return await Promise.all([
    fetch("./glsl/common.glsl").then((res) => res.text()),
    fetch("./glsl/canvas.glsl").then((res) => res.text()),
    fetch("./glsl/agents.glsl").then((res) => res.text()),
    fetch("./glsl/points.glsl").then((res) => res.text()),
    fetch("./glsl/trails.glsl").then((res) => res.text()),
  ]);
}

function setup() {
  fetchglsl().then((glsl) => main(glsl));
}

function clipspacequad() {
  let model = {
    index: [0, 1, 2, 2, 3, 0],
    clipspace: [-1, -1, 1, -1, 1, 1, -1, 1],
    uv: [0, 0, 1, 0, 1, 1, 0, 1],
  };
  return model;
}

function shaderlayout() {
  let layout = {
    attributes: {
      clipspace: 2,
      uv: 2,
    },
    uniforms: {
      iTime: "uniform1f",
      iResolution: "uniform2fv",
      texture0: "uniform1i",
      texture1: "uniform1i",
      sqrtNagents: "uniform1i",
      mousePos: "uniform2fv",
    },
  };

  let uniforms = {
    iTime: 0.0,
    iResolution: [100, 100],
    texture0: 0,
    texture1: 1,
    sqrtNagents: 200,
    mousePos: [-1, -1],
  };

  return [layout, uniforms];
}

function relativeEventPos(e) {
  let rect = e.target.getBoundingClientRect();
  let x = e.clientX - rect.left;
  let y = rect.height - (e.clientY - rect.top);
  return [x / rect.width, y / rect.height];
}

function debounce(fn, ms) {
  //only call fn if it has not been called in the last ms interval
  let timer;
  return (_) => {
    clearTimeout(timer);
    timer = setTimeout((_) => {
      timer = null;
      fn.apply(this, arguments);
    }, ms);
  };
}

function handleSizing(canvas) {
  const aspectratio = 21 / 9;
  const { width } = canvas.getBoundingClientRect();
  const height = Math.round(width / aspectratio);
  canvas.width = width;
  canvas.height = height;
}

function readPixelsFromBuffer(gl, fb) {
  gl.bindFramebuffer(gl.FRAMEBUFFER, fb.id2);
  gl.readBuffer(gl.COLOR_ATTACHMENT0);
  const data = new Uint8Array(4 * fb.width * fb.height);
  gl.readPixels(0, 0, fb.width, fb.height, gl.RGBA, gl.UNSIGNED_BYTE, data);
  console.log("readPixelsFromBuffer, data:", data);
  return data;
}

function main(glsl) {
  const canvas = document.getElementById("canvas");
  const [layout, uniforms] = shaderlayout();

  handleSizing(canvas);
  window.addEventListener(
    "resize",
    debounce(() => handleSizing(canvas), 100)
  );

  canvas.addEventListener("mousedown", (e) => {
    let [x, y] = relativeEventPos(e);
    uniforms.mousePos = [x, y];
  });

  canvas.addEventListener("mousemove", (e) => {
    if (uniforms.mousePos[0] > 0) {
      let [x, y] = relativeEventPos(e);
      uniforms.mousePos = [x, y];
    }
  });

  canvas.addEventListener("mouseup", (e) => {
    uniforms.mousePos = [-1, -1];
  });

  const gl = glcontext(canvas);

  const fb = {};
  fb.canvas = frameBuffer_canvas(canvas);
  fb.agents = frameBuffer(gl, uniforms.sqrtNagents, uniforms.sqrtNagents, {
    randomfill: true,
    linearfilter: false,
  });
  fb.points = frameBuffer(gl, 21 * 100, 9 * 100);
  fb.trails = frameBuffer(gl, 21 * 100, 9 * 100);
  //resolveFramebufferTexture(gl, fb.agents); //prevent initial "warning: lazy initialization" aka null texture
  //resolveFramebufferTexture(gl, fb.trails);
  //resolveFramebufferTexture(gl, fb.points);
  console.log("fb", fb);

  //let pixeldata = readPixelsFromBuffer(gl, fb.agents); //debug

  const program = {};
  program.canvas = createProgram(gl, layout, glsl[0], glsl[1]);
  program.agents = createProgram(gl, layout, glsl[0], glsl[2]);
  program.points = createProgram(gl, layout, glsl[0], glsl[3]);
  program.trails = createProgram(gl, layout, glsl[0], glsl[4]);
  console.log("program", program);

  const vao = {};
  vao.clipspacequad = vertexArray(gl, program.canvas, clipspacequad());
  vao.clipspacequad2 = vertexArray(gl, program.agents, clipspacequad());
  vao.clipspacequad3 = vertexArray(gl, program.trails, clipspacequad());

  let animstart = performance.now();
  const animate = (timestamp) => {
    uniforms.iTime = (timestamp - animstart) / 1000;

    setFrameBuffer(gl, fb.agents);
    uniforms.iResolution = [fb.agents.width, fb.agents.height];
    draw(gl, program.agents, vao.clipspacequad2, uniforms, [
      fb.agents.texture,
      fb.trails.texture,
    ]);
    resolveFramebufferTexture(gl, fb.agents);

    setFrameBuffer(gl, fb.points);
    clear(gl);
    uniforms.iResolution = [fb.points.width, fb.points.height];
    let Npoints = fb.agents.width * fb.agents.height;
    drawPoints(gl, program.points, uniforms, Npoints, [fb.agents.texture]);
    resolveFramebufferTexture(gl, fb.points);

    setFrameBuffer(gl, fb.trails);
    uniforms.iResolution = [fb.trails.width, fb.trails.height];
    draw(gl, program.trails, vao.clipspacequad3, uniforms, [
      fb.points.texture,
      fb.trails.texture,
    ]);
    resolveFramebufferTexture(gl, fb.trails);

    setFrameBuffer(gl, fb.canvas, canvas.width, canvas.height);
    //clear(gl);
    uniforms.iResolution = [canvas.width, canvas.height];
    draw(gl, program.canvas, vao.clipspacequad, uniforms, [fb.trails.texture]);

    animframe = requestAnimationFrame(animate);
  };
  animframe = requestAnimationFrame(animate);
}

window.onload = setup();

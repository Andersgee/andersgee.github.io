#version 300 es
precision mediump float;
precision mediump int;
precision mediump sampler2D;
// setting a precision is REQUIRED for some reason

#define clamp01(x) clamp(x, 0.0, 1.0)
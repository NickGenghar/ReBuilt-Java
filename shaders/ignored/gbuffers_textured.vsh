#version 120

varying vec2 texcoord;
varying vec3 pos;
varying vec4 color;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;

    pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    gl_Position = gl_ProjectionMatrix * vec4(pos, 1.0);
}
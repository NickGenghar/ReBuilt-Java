#version 120

varying vec2 texcoord;
varying vec4 pos;

void main() {
	pos = gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * pos;
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
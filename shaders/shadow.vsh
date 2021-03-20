#version 120 

#include "/util/shadow/distort.glsl"

varying vec4 color;
varying vec2 texcoord;

void main(){
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	color = gl_Color;

	gl_Position = ftransform();
	gl_Position.xyz = distort(gl_Position.xyz);
}

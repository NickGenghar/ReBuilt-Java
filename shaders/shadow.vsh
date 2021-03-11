#version 120 

#include "/util/distort.glsl"

varying vec2 texcoord, lmcoord;
varying vec4 color;

uniform mat4 shadowProjection, shadowProjectionInverse, shadowModelView, shadowModelViewInverse;

void main(){
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy, lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	color = gl_Color;

	//vec4 position = shadowModelViewInverse * shadowProjectionInverse * ftransform();
	gl_Position = ftransform();//shadowProjection * shadowModelView * position;
	gl_Position.xyz = distort(gl_Position.xyz);
}

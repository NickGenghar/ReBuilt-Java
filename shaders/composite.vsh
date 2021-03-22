#version 120

uniform mat4 gbufferProjection;
uniform float aspectRatio;
uniform vec3 sunColor, sunPosition;

varying vec4 viewPos;
varying vec3 sunPos;
varying vec2 texcoord;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	viewPos = gl_ModelViewMatrix * gl_Vertex;
	gl_Position = gl_ProjectionMatrix * viewPos;

	vec4 sunViewPos = gbufferProjection * vec4(sunPosition, 1.0);
	sunViewPos = vec4(sunViewPos.xyz / sunViewPos.w, sunViewPos.w);
	sunPos = vec3((sunViewPos.xy / sunViewPos.z) * 0.5 + 0.5, sunPosition.z);
}
#version 120

#include "/util/tonemap.glsl"

uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D depthtex1;
uniform vec3 fogColor;

varying vec2 texcoord;
varying vec3 sunPos;
varying vec4 viewPos;

void main() {
    vec3 diffuse = texture2D(gcolor, texcoord).rgb;
	float depth = texture2D(depthtex1, texcoord).r;
    diffuse = TONEMAP_OPERATOR(diffuse);

	if(abs(-sign(sunPos.z)) == 1.0 && depth == 1.0) {
		diffuse += 1.0 / (1.0 + dot(sunPos.xy, sunPos.xy));
	}

/* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(diffuse, 1.0); //gcolor
}
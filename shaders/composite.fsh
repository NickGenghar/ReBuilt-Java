#version 120

#include "/util/tonemap.glsl"

uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform float frameTimeCounter;
uniform vec3 fogColor;

varying vec2 texcoord;
varying vec4 pos;

void main() {
    vec3 diffuse = texture2D(gcolor, texcoord).rgb;
    diffuse = TONEMAP_OPERATOR(diffuse);
	//diffuse = mix(diffuse, fogColor, clamp(-length(pos), 0., 1.));

/* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(diffuse, 1.0); //gcolor
}
#version 120

#include "/util/postprocess/tonemap.glsl"
#include "/util/postprocess/godrays.glsl"
#include "/util/misc/fog.glsl"

uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0, shadowtex1;
uniform sampler2D depthtex0, depthtex1;
uniform mat4 gbufferProjection;
uniform vec3 fogColor, sunPosition;

varying vec4 viewPos;
varying vec3 sunPos;
varying vec2 texcoord;

void main() {
    vec3 albedo1 = texture2D(gcolor, texcoord).rgb;
	vec3 albedo2 = texture2D(gcolor, texcoord).rgb;
	float depth = texture2D(depthtex1, texcoord).r;

    albedo1 = TONEMAP_OPERATOR(albedo1);
	albedo1.rgb = doGodrays(albedo1.rgb, sunPos.xy, texcoord);
	albedo1.rgb = doFog(albedo1.rgb, texcoord);

/* DRAWBUFFERS:03 */
    gl_FragData[0] = vec4(albedo1, 1.0);
	gl_FragData[1] = vec4(albedo2, 1.0);
}
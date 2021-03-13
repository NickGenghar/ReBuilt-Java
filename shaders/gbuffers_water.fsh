#version 120

#include "/util/waves.glsl"
#include "/util/distort.glsl"

uniform sampler2D texture, lightmap;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

uniform float frameTimeCounter;

varying vec2 texcoord, lmcoord;
varying vec4 color, pos, shadowPos;
varying vec3 entity;

const bool shadowcolor0Nearest = true;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

void main() {
    vec4 albedo = texture2D(texture, texcoord) * color;
    vec2 lm = lmcoord;

    #ifdef ENABLE_WAVE
        if(entity.x == 10000)
        albedo +=  0.08 * getwaves(pos.xz / 8.0, frameTimeCounter);
    #endif

	#if SHADOW_MODE == 1
		if (shadowPos.w > 0.0) {
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
				lm.y *= SHADOW_BRIGHTNESS;
			} else {
				lm.y = mix(31.0 / 32.0 * SHADOW_BRIGHTNESS, 31.0 / 32.0, sqrt(shadowPos.w));
				if(texture2D(shadowtex0, shadowPos.xy).r < shadowPos.z) {
					vec4 shadowLightColor = texture2D(shadowcolor0, shadowPos.xy);
					shadowLightColor.rgb = sqrt(shadowLightColor.rgb);
					shadowLightColor.rgb = mix(vec3(1.0), shadowLightColor.rgb, shadowLightColor.a);
					shadowLightColor.rgb = mix(shadowLightColor.rgb, vec3(1.0), lm.x);
					albedo.rgb *= shadowLightColor.rgb;
				}
			}
		}
		albedo *= texture2D(lightmap, lm);
	#elif SHADOW_MODE == 2
		vec4 ambient = texture2D(lightmap, vec2(lm.x, drawBedrockShadow(lm.y, 0.6, 3.0)));
		albedo *= ambient;
	#endif

/* DRAWBUFFERS:0 */
    gl_FragData[0] = albedo;
}
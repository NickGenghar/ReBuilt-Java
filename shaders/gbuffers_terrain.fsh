#version 120

#include "/util/values.glsl"

uniform sampler2D texture, lightmap;

varying vec2 texcoord, lmcoord;
varying vec4 color, pos;

uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec4 shadowPos;

const int shadowMapResolution = 512; //WARNING! ANYTHING HIGHER THAN 2048 IS OVERKILL! [128 256 512 1024 2048 4096 8192]

float drawBedrockShadow(float Y, float lD, float lS) {
	float bias = (((lS - 1.0) * -0.1) / 9.0) + 1.0;
	return max(Y * lD, pow(Y, lS)/bias);
}

void main() {
	vec4 albedo = texture2D(texture, texcoord) * color;
	vec2 lm = lmcoord;

	#if SHADOW_MODE == 1
		if (shadowPos.w > 0.0) {
			if (texture2D(shadowtex1, shadowPos.xy).r < shadowPos.z) {
				lm.y *= SHADOW_BRIGHTNESS;
			} else {
				lm.y = mix(31.0 / 32.0 * SHADOW_BRIGHTNESS, 31.0 / 32.0, sqrt(shadowPos.w));
				if(texture2D(shadowtex0, shadowPos.xy).r < shadowPos.z) {
					vec4 shadowLightColor = texture2D(shadowcolor0, shadowPos.xy);
					shadowLightColor.rgb = mix(vec3(1.0), shadowLightColor.rgb, shadowLightColor.a);
					shadowLightColor.rgb = mix(shadowLightColor.rgb, vec3(1.0), lm.x);
					shadowLightColor.rgb *= 2. * SHADOW_BRIGHTNESS;
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
#version 120

#include "/util/shadow/distort.glsl"

#define Torch_Red 0.60 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define Torch_Green 0.30 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]
#define Torch_Blue 0.10 // [0.00 0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]

uniform sampler2D texture, lightmap;
uniform sampler2D shadowcolor0;

/*
Very mind-blowing...
If I do:
uniform sampler2D shadowtex0, shadowtex1;

instead of:
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

shadows breaks and doesn't render.
But apparently it renders back to normal if I set it as the second one...
And surprisingly other programs can just do the first one no problem...

FOR FUCK SAKE I CAN'T JUST DO uniform sampler2D shadowtex0, shadowtex1; WITHOUT BREAKING SHAODWS!!!
*/

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

varying vec4 color, shadowPos;
varying vec2 texcoord, lmcoord;

const bool shadowcolor0Nearest = true;
const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;

void main() {
	vec4 albedo = texture2D(texture, texcoord) * color;
	vec2 lm = lmcoord;

	vec3 torchColor = vec3(Torch_Red, Torch_Green, Torch_Blue) * lm.x;
	albedo.rgb = mix(mix(albedo.rgb, pow(albedo.rgb + torchColor, vec3(2.)), lm.x), albedo.rgb, texture2D(lightmap, vec2(0., lm.y)).g);

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
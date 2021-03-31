#version 120

#define ENABLE_GODRAYS //Enables or disables God rays.
#define GODRAYS_SAMPLES 32 //Sample count for doing God rays. WARNING! ANYTHING HIGHER THAN 64 IS OVERKILL!!! [8 16 32 64 128 256 512]
#define GODRAYS_VARIANCE 6 //Variance imposed on the God rays. WARNING! ANYTHING HIGHER THAN 8 IS OVERKILL!!! [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]

#include "/util/postprocess/tonemap.glsl"
#include "/util/common/dither.glsl"

uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0, shadowtex1;
uniform sampler2D depthtex0, depthtex1;
uniform mat4 gbufferProjection;
uniform vec3 fogColor, sunPosition;
uniform float aspectRatio;

varying vec4 viewPos;
varying vec3 sunPos;
varying vec2 texcoord;

void main() {
    vec3 albedo1 = texture2D(gcolor, texcoord).rgb;
	vec3 albedo2 = texture2D(gcolor, texcoord).rgb;
	float depth = texture2D(depthtex1, texcoord).r;
	vec2 sp = (sunPos.xy - texcoord) / (vec2(1.0, aspectRatio)*0.04);

    albedo1 = TONEMAP_OPERATOR(albedo1);

	float sun = 1.0 / (1.0 + dot(sp, sp));
	#ifdef ENABLE_GODRAYS
		vec2 sunScreenPosGodrays = ((sunPos.xy - texcoord) * 0.001) / (GODRAYS_SAMPLES * 0.001);
		float acc = 0.0;
        float jitter = bayer(gl_FragCoord.xy, GODRAYS_VARIANCE);
		vec2 acc_coord = texcoord + sunScreenPosGodrays * jitter;
        int i = 0;
		while(i++ < GODRAYS_SAMPLES) {
            float d = texture2D(depthtex1, acc_coord).r;

			if(d == 1.0) acc += 1.0;
			acc_coord += sunScreenPosGodrays;
		}
		acc /= GODRAYS_SAMPLES;
		albedo1.rgb += sun * acc;
	#else
		if(depth == 1.0)
		albedo1.rgb += sun;
	#endif

/* DRAWBUFFERS:03 */
    gl_FragData[0] = vec4(albedo1, 1.0);
	gl_FragData[1] = vec4(albedo2, 1.0);
}
#version 120

#define GODRAYS //Enables or disables God rays.
#define GODRAYS_SAMPLE 32 //Sample count for doing God rays. WARNING! ANYTHING HIGHER THAN 64 IS OVERKILL!!! [8 16 32 64 128 256 512]
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
    vec3 diffuse = texture2D(gcolor, texcoord).rgb;
	float depth = texture2D(depthtex1, texcoord).r;
	vec2 sp = (sunPos.xy - texcoord) / (vec2(1.0, aspectRatio)*0.04);

    diffuse = TONEMAP_OPERATOR(diffuse);

	float sun = 1.0 / (1.0 + dot(sp, sp));
	#ifdef GODRAYS
		vec2 sunScreenPosGodrays = ((sunPos.xy - texcoord) * 0.001) / (GODRAYS_SAMPLE * 0.001);
		float acc = 0.0;
        float jitter = bayer(gl_FragCoord.xy, GODRAYS_VARIANCE);
		vec2 acc_coord = texcoord + sunScreenPosGodrays * jitter;
        int i = 0;
		while(i++ < GODRAYS_SAMPLE) {
            float d = texture2D(depthtex1, acc_coord).r;

			if(d == 1.0) acc += 1.0;
			acc_coord += sunScreenPosGodrays;
		}
		acc /= GODRAYS_SAMPLE;
		diffuse.rgb += sun * acc;
	#else
		if(depth == 1.0)
		diffuse.rgb += sun;
	#endif

	/* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(diffuse, 1.0); //gcolor
}
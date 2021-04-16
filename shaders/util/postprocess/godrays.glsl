#include "/util/common/dither.glsl"

#define ENABLE_GODRAYS //Enables or disables God rays.
#define GODRAYS_SAMPLES 32 //Sample count for doing God rays. WARNING! ANYTHING HIGHER THAN 64 IS OVERKILL!!! [8 16 32 64 128 256 512]
#define GODRAYS_VARIANCE 6 //Variance imposed on the God rays. WARNING! ANYTHING HIGHER THAN 8 IS OVERKILL!!! [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]

uniform float aspectRatio;

vec3 doGodrays(vec3 color, vec2 sunPos, vec2 texcoord) {
	float depth = texture2D(depthtex1, texcoord).r;
	vec2 sp = (sunPos - texcoord) / (vec2(1.0, aspectRatio)*0.04);

    float inView = clamp(dot(normalize(sunPosition), vec3(0.0)), 0.0, 1.0);
	float sun = (1.-(inView*.5))*exp(-dot(sp,sp))+(inView*.5+.2);

    #ifdef ENABLE_GODRAYS
        vec2 sunScreenPosGodrays = ((sunPos - texcoord) * 0.001) / (GODRAYS_SAMPLES * 0.001);
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
        color += sun * acc;
    #else
		if(depth == 1.0)
		color += sun;
    #endif

    return color;
}
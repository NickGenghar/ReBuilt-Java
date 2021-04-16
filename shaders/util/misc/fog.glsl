#define ENABLE_FOG //Enables or disables fog.

uniform mat4 gbufferProjectionInverse;
uniform float far;
uniform sampler2D depthtex0;

vec3 doFog(vec3 color, vec2 texcoord) {
    float depth = texture2D(depthtex0, texcoord).r;

    #ifdef ENABLE_FOG
        vec3 sPos = vec3(texcoord, depth);
        vec3 cPos = sPos * 2.0 - 1.0;
        vec4 tmp = gbufferProjectionInverse * vec4(cPos, 1.0);
        vec3 vPos = tmp.xyz/tmp.w;

        float dist = length(vPos) / far;
        dist = smoothstep(0.0, 1.0, dist);

        if(depth < 1.0)
        color = mix(color, fogColor, clamp(dist, 0.0, 1.0));
    #endif
    return color;
}
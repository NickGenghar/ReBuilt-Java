#version 120

#define ENABLE_FOG //Enables or disables fog.

uniform mat4 gbufferProjectionInverse;
uniform sampler2D gcolor, depthtex0;
uniform vec3 fogColor;
uniform float far;

varying vec2 texcoord;

void main() {
    vec4 diffuse = texture2D(gcolor, texcoord);
    float depth = texture2D(depthtex0, texcoord).r;

    #ifdef ENABLE_FOG
        vec3 sPos = vec3(texcoord, depth);
        vec3 cPos = sPos * 2.0 - 1.0;
        vec4 tmp = gbufferProjectionInverse * vec4(cPos, 1.0);
        vec3 vPos = tmp.xyz/tmp.w;

        float dist = length(vPos) / far;
        dist = smoothstep(0.0, 1.0, dist);

        if(depth < 1.0)
        diffuse.rgb = mix(diffuse.rgb, fogColor, clamp(dist, 0.0, 1.0));
    #endif

    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = diffuse;
}
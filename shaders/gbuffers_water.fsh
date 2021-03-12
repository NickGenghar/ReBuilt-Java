#version 120

#include "/util/waves.glsl"

uniform sampler2D texture;

uniform float frameTimeCounter;

varying vec2 texcoord;
varying vec4 color, pos;
varying vec3 entity;

void main() {
    vec4 albedo = texture2D(texture, texcoord) * color;
    #ifdef ENABLE_WAVE
        if(entity.x == 10000)
        albedo +=  0.2 * wave(pos.xyz, frameTimeCounter);
    #endif

/* DRAWBUFFERS:0 */
    gl_FragData[0] = albedo;
}
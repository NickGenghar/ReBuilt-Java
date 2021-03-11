#version 120

#include "/util/waves.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

attribute vec3 mc_Entity;

varying vec2 texcoord;
varying vec4 color, pos;
varying vec3 entity;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    color = gl_Color;
    entity = mc_Entity;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPos = gl_ProjectionMatrix * viewPos;
    pos = gbufferModelViewInverse * viewPos + vec4(cameraPosition, 1.0);

    #ifdef ENABLE_WAVE
        if(mc_Entity.x != 10000.0)
        worldPos.y += wave(pos.xyz, frameTimeCounter);
    #endif

    gl_Position = worldPos;
}
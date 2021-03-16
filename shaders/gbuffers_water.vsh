#version 120

#include "/util/waves.glsl"
#include "/util/distort.glsl"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

attribute vec3 mc_Entity;

varying vec2 texcoord, lmcoord;
varying vec4 color, pos, shadowPos;
varying vec3 entity;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    entity = mc_Entity;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPos = gl_ProjectionMatrix * viewPos;
    pos = gbufferModelViewInverse * viewPos + vec4(cameraPosition, 1.0);

    #if SHADOW_MODE == 1
        float lightDot = dot(normalize(shadowLightPosition), normalize(gl_NormalMatrix * gl_Normal));

        if(lightDot > 0.) {
            vec4 playerPos = gbufferModelViewInverse *  viewPos;
            shadowPos = shadowProjection * (shadowModelView * playerPos);
            float distortFactor = getDistortFactor(shadowPos.xy);
            shadowPos.xyz = distort(shadowPos.xyz, distortFactor);
            shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;
            shadowPos.z -= SHADOW_BIAS * (distortFactor * distortFactor) / abs(lightDot);
        } else {
            lmcoord.y *= SHADOW_BRIGHTNESS;
            shadowPos = vec4(0.);
        }

        shadowPos.w = lightDot;
    #endif

    #ifdef ENABLE_WAVE
        if(entity.x == 10000)
        worldPos.y += getwaves(pos.xz, frameTimeCounter);

        if(entity.x == 10001)
        worldPos.y += 0.8 * getwaves(pos.xz, frameTimeCounter);
    #endif

    gl_Position = worldPos;
}
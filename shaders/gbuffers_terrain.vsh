#version 120

#include "/util/waves.glsl"
#include "/util/distort.glsl"

attribute vec3 mc_Entity;

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

varying vec2 texcoord, lmcoord;
varying vec4 color;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform vec3 shadowLightPosition;

varying vec4 shadowPos;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    color = gl_Color;
    vec3 entity = mc_Entity;

    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vec4 worldPos = gl_ProjectionMatrix * viewPos;
    vec4 pos = gbufferModelViewInverse * viewPos + vec4(cameraPosition, 1.0);

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
        if(entity.x == 10001) {
            worldPos.x += leaves(pos.xyz, frameTimeCounter);
        }
    #endif

    gl_Position = worldPos;
}
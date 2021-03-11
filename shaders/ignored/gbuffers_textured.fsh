#version 120

#include "/util/values.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec3 pos;
varying vec4 color;

void main() {
    vec4 albedo = texture2D(texture, texcoord) * color;
    vec3 fogColor = vec3(float(FOG_RED) / 255., float(FOG_GREEN) / 255., float(FOG_BLUE) / 255.);
    albedo.rgb = mix(albedo.rgb, color.rgb, length(pos));

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = albedo;
}
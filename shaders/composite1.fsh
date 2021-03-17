#version 120

#include "/util/dof.glsl"

uniform sampler2D gcolor;
uniform sampler2D depthtex1;

varying vec2 texcoord;

void main() {
    vec4 diffuse = texture2D(gcolor, texcoord);
    float depth = texture2D(depthtex1, texcoord).r;

    #ifdef DEPTH_OF_FIELD
        diffuse.rgb = DoF(gcolor, texcoord, diffuse.rgb, depth);
    #endif

/* DRAWBUFFERS: 0 */
    gl_FragData[0] = diffuse;
}
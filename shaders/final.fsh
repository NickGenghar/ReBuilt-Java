#version 120

#define DEBUG 0 //Cycles between the debug views. [0 1 2]

#include "/util/postprocess/dof.glsl"
#include "/util/postprocess/bloom.glsl"

uniform sampler2D gcolor;
uniform sampler2D depthtex1;

uniform sampler2D colortex1, colortex2, colortex3;

varying vec2 texcoord;

void main() {
    vec4 albedo = texture2D(gcolor, texcoord);
    vec4 normalView = texture2D(colortex1, texcoord);
    vec4 specularView = texture2D(colortex2, texcoord);
    float depth = texture2D(depthtex1, texcoord).r;

    /*
    #ifdef ENABLE_BLOOM
        if(depth < 1.0)
        albedo.rgb = bloom(colortex2, colortex3, texcoord, albedo.rgb);
    #endif
    /**/

    #ifdef ENABLE_DOF
        albedo.rgb = DoF(gcolor, texcoord, albedo.rgb, depth);
    #endif

    #if DEBUG == 0
        gl_FragColor = albedo;
    #elif DEBUG == 1
        gl_FragColor = normalView;
    #elif DEBUG == 2
        gl_FragColor = specularView;
    #endif
}
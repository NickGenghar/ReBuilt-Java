#version 330 compatibility

#include "/util/postprocess/dof.glsl"
//imports: doDepthOfField

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    color = texture(colortex0, texcoord);
    float depth = texture(depthtex0, texcoord).r;
    
    #ifdef ENABLE_DOF
        color.rgb = doDepthOfField(colortex0, texcoord, color.rgb, depth, true);
    #endif
}
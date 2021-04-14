#version 120

uniform sampler2D gcolor;

varying vec2 texcoord;

void main() {
    vec4 diffuse = texture2D(gcolor, texcoord);
    /* DRAWBUFFERS: 0 */
    gl_FragData[0] = diffuse;
}
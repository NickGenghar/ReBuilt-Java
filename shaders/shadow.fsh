#version 120 

uniform sampler2D texture, lightmap;

varying vec2 texcoord, lmcoord;
varying vec4 color;

void main(){
    vec4 albedo = texture2D(texture, texcoord) * color;

	gl_FragData[0] = albedo;
}

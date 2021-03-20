#version 120 

uniform sampler2D texture;

varying vec4 color;
varying vec2 texcoord;

const int shadowMapResolution = 512; //WARNING! ANYTHING HIGHER THAN 2048 IS OVERKILL! [128 256 512 1024 2048 4096 8192]

void main(){
    vec4 albedo = texture2D(texture, texcoord) * color;

	gl_FragData[0] = albedo;
}

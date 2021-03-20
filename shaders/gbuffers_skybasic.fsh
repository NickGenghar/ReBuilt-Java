#version 120

uniform mat4 gbufferModelView, gbufferProjectionInverse;
uniform vec3 fogColor, skyColor;
uniform float viewHeight, viewWidth;

varying vec4 starData;

const float sunPathRotation = 0.0; //Sun rotation. [-45.0 -30.0 -15.0 0.0 15.0 30.0 45.0]

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz); //not much, what's up with you?
	return mix(skyColor * 0.5, fogColor, fogify(max(upDot, 0.0), 0.0625));
}

void main() {
    vec3 albedo;
    if(starData.a > 0.5) {
        albedo = starData.rgb;
    } else {
        vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
        pos = gbufferProjectionInverse * pos;
        albedo = calcSkyColor(normalize(pos.xyz));
    }

    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(albedo, 1.0);
}
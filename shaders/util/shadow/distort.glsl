#define SHADOW_BRIGHTNESS 0.50 // [0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75]
#define SHADOW_BIAS 0.02 // [0.01 0.02 0.03 0.04 0.05]
#define SHADOW_MODE 1 //Choose between Off, Java, and Bedrock. 0 = Off: No shadow, No performance impact. 1 = Java: True shadow, Significant performance impact. 2 = Bedrock: "Bedrock Edition" style shadow, Low performance impact. [0 1 2]

float cubeLength(vec2 v) {
	return pow(abs(v.x * v.x * v.x) + abs(v.y * v.y * v.y), 1.0 / 3.0);
}
	
float getDistortFactor(vec2 v) {
	return cubeLength(v) + 0.1;
}

vec3 distort(vec3 v, float factor) {
	return vec3(v.xy / factor, v.z * 0.5);
}

vec3 distort(vec3 v) {
	return distort(v, getDistortFactor(v.xy));
}

float drawBedrockShadow(float Y, float lD, float lS) {
	float bias = (((lS - 1.0) * -0.1) / 9.0) + 1.0;
	return max(Y * lD, pow(Y, lS)/bias);
}
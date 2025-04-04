#define ENABLE_DOF //Enables or disables depth of field.
#define DOF_SAMPLES 3 //Sample pass used for the depth of field. WARNING! ANYTHING HIGHER THAN 10 IS OVERKILL! [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
#define DOF_SIZE 5 //Sample size used for the depth of field. WARNING! ANYTHING HIGHER THAN 15 IS OVERKILL! [1 3 5 7 9 11 13 15 17 19 21 23 25]
#define DOF_STRENGTH 0.50 //Sample stregth used for the depth of field. [0.00 0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00 5.25 5.50 5.75 6.00 6.25 6.50 6.75 7.00 7.25 7.50 7.75 8.00]
#define DOF_RADIUS 1 //Sample radius used for the depth of field. [1 2 3 4 5 6 7 8]

#include "/util/common/blur.glsl"
/*imports:
    gaussian_naive
    PI
*/
//const float PI = 3.1415926535897932384626434; //custom uniform defined in shaders.properties

uniform float centerDepthSmooth, aspectRatio;

vec3 DoF(in sampler2D tex, in vec2 coord, vec3 c, float z) {
	vec3 dof = vec3(0.0);

    float coc = max(abs(z - centerDepthSmooth) * DOF_STRENGTH * 0.25, 0.0);
    coc = coc / sqrt(coc * coc + 0.1); //Lorentz curve

	if(coc > 0.0 && float(z < 0.56) < 0.5) {
		for(float i = 0.0; i < PI; i += PI/float(DOF_SAMPLES)) {
            for(float j = 1.0/float(DOF_SIZE); j <= 1.0; j += 1.0/float(DOF_SIZE)) {
                vec2 offset = vec2(cos(i), sin(i)) * float(DOF_RADIUS) * j * coc * vec2(1.0 / aspectRatio, 1.0);
                dof += texture2D(tex, coord + offset).rgb;
            }
		}
        dof /= float(DOF_SIZE * DOF_SAMPLES);
	} else {
		dof = c;
	}

    return dof;
}

vec3 doDepthOfField(in sampler2D tex, in vec2 coord, in vec3 c, float z, bool dir) {
    vec3 result = vec3(0.0);
    float samples = float(DOF_SAMPLES);
    float weight = 0.0;
    float acc = 0.0;

    float coc = max(abs(z - centerDepthSmooth) * DOF_STRENGTH * 0.005, 0.0);
    coc = coc / sqrt(coc * coc + 0.1); //Lorentz curve

    //Ignores hand
    //Without this if-else, your hands are going to be affected by the dof,
    //looking exceptionally ugly.
    if (coc > 0.0 && float(z < 0.56) < 0.5)
    for(float i = -samples / 2.0; i < samples / 2.0; i += 1.0/samples) {
        weight = gaussian_naive(i);
        vec2 offset = dir ? vec2(0.0, i) : vec2(i * (1.0/aspectRatio), 0.0);
        offset *= float(DOF_SIZE);
        result += texture2D(tex, coord + coc * offset).rgb * weight;
        result += texture2D(tex, coord - coc * offset).rgb * weight;
        acc += weight * 2.;
    }
    else
    return result = c;

    result /= acc;
    return result;
}
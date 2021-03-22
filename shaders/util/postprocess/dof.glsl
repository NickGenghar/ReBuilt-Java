#define ENABLE_DOF //Enables or disables depth of field.
#define DOF_SAMPLES 3 //Sample pass used for the depth of field. WARNING! ANYTHING HIGHER THAN 10 IS OVERKILL! [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]
#define DOF_SIZE 5 //Sample size used for the depth of field. WARNING! ANYTHING HIGHER THAN 15 IS OVERKILL! [1 3 5 7 9 11 13 15 17 19 21 23 25]
#define DOF_STRENGTH 0.50 //Sample stregth used for the depth of field. [0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define DOF_RADIUS 1 //Sample radius used for the depth of field. [1 2 3 4 5 6 7 8]

//From: https://en.wikipedia.org/wiki/Pi
#define PI 3.1415926535897932384626434

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
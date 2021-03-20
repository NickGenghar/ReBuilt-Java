#define ENABLE_WAVE //Globally enables or disables waves.
#define DRAG_MULT 0.048 // [0.012 0.024 0.036 0.048 0.060 0.072 0.094 0.096 0.108]
#define iterations 3 //Wave sample counts. WARNING! ANYTHING HIGHER THAN 5 IS OVERKILL! [1 2 3 4 5 6 7 8 9 10 11 12 13]
#define SPEED_MULT 1.0 //Global Wave speed multiplier. [0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0 2.2 2.4 2.6 2.8 3.0 3.2 3.4 3.6 3.8 4.0]

float waveGen(int mode, float dimension, float amplitude, float frequency, float phase) {
    float result;
    if(mode == 0) {
        result = amplitude * sin(frequency + (dimension + phase));
    } else if(mode == 1) {
        result = amplitude * cos(frequency + (dimension + phase));
    } else if(mode == 2) {
        result = amplitude * tan(frequency + (dimension + phase));
    } else {
        result = 0.0;
    }

    return result;
}

float leaves(vec3 bp, float t) {
    const int i = 2; //KEEP THIS VALUE THE SAME AS THE NUMBER OF ARRAY ELEMENTS OR ELSE IT WILL BREAK!!!
    float wave = 0.0;
    float waves[i] = float[] (
        waveGen(0, bp.x*0.8 + bp.z*0.7 + bp.y * 0.8, 0.03, t * 1.55 * SPEED_MULT, 0.0),
        waveGen(0, bp.x*0.6 - bp.z*0.9 - bp.y * 0.6 , 0.05, t * 1.95 * SPEED_MULT, 2.4)
    );

    for(int j = 0; j < i; j++) {
        wave += waves[j];
    }
    return  wave;
}

vec2 wavedx(vec2 position, vec2 direction, float speed, float frequency, float timeshift) {
    float x = dot(direction, position) * frequency + timeshift * speed;
    float wave = exp(sin(x) - 1.0);
    float dx = wave * cos(x);
    return vec2(wave, -dx);
}

float getwaves(vec2 position, float frameTimeCounter){
	float iter = 0.0;
    float phase = 6.0;
    float speed = 2.0 * SPEED_MULT;
    float weight = 1.0;
    float w = 0.0;
    float ws = 0.0;
    for(int i=0;i<iterations;i++){
        vec2 p = vec2(sin(iter), cos(iter));
        vec2 res = wavedx(position, p, speed, phase, frameTimeCounter);
        position += normalize(p) * res.y * weight * DRAG_MULT;
        w += res.x * weight;
        iter += 12.0;
        ws += weight;
        weight = mix(weight, 0.0, 0.2);
        phase *= 1.18;
        speed *= 1.07;
    }
    return (w / ws) - 0.7;
}

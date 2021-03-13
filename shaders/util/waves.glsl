#define ENABLE_WAVE //Enables or disables wave. Rudimentary, so there's room for improvements
#define DRAG_MULT 0.048 // [0.012 0.024 0.036 0.048 0.060 0.072 0.094 0.096 0.108]
#define iterations 5 //Wave sample counts. WARNING! ANYTHING HIGHER THAN 5 IS OVERKILL! [1 2 3 4 5 6 7 8 9 10 11 12 13]

float wave(vec3 s, float time) {
    return 0.13 * sin(time * 0.42 + s.x * 2.2) + 0.15 * sin(time * 0.44 + s.z * 2.3);
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
    float speed = 2.0;
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

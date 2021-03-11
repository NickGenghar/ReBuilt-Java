#define ENABLE_WAVE //Enables or disables wave. Rudimentary, so there's room for improvements

float wave(vec3 s, float time) {
    return 0.13 * sin(time * 0.42 + s.x * 2.2) + 0.15 * sin(time * 0.44 + s.z * 2.3);
}
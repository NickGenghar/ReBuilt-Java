#define ENABLE_BLOOM
#define BLOOM_SAMPLES 15 //Sample counts for Bloom. WARNING! ANYTHING HIGHER THAN 17 IS OVERKILL!!! [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35]
#define BLOOM_STRENGTH 2.0 //Sample strength for Bloom. [1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.0 7.5 8.0]
#define BLOOM_INTENSITY 0.25 //Bloom intensity. [0.25 0.50 0.75 1.00 1.25 1.50 1.75 2.00]
#define BLOOM_THRESHOLD 1.0 //Bloom threshold. [0.25 0.50 0.75 1.00]

#define ENABLE_SPECULAR

uniform float viewWidth, viewHeight;

#define pow2(x) (x * x)

const float sigma = float(BLOOM_SAMPLES) * BLOOM_INTENSITY;

float gaussian(vec2 i) {
    return 1.0 / (2.0 * pi * pow2(sigma)) * exp(-((pow2(i.x) + pow2(i.y)) / (2.0 * pow2(sigma))));
}

vec3 blur(in sampler2D tex, in vec2 coord) {
    vec3 s = vec3(0.0);
    vec2 pixelSize = vec2(1.0) / vec2(viewWidth, viewHeight);
    float t = 0.0;
    float weight;

    //2 passes, 1 for each coord because f(x*y) is expensive as fuck compared to f(x)+f(y)
    for(int i = -BLOOM_SAMPLES; i <= BLOOM_SAMPLES; i++) {
        vec2 offset = vec2(i * pixelSize.x,0.);
        weight = gaussian(offset);
        s += texture2D(tex, coord + offset * BLOOM_STRENGTH).rgb * weight;
        s += texture2D(tex, coord - offset * BLOOM_STRENGTH).rgb * weight;
        t += weight * 2.0;
    }

    for(int j = -BLOOM_SAMPLES; j <= BLOOM_SAMPLES; j++) {
        vec2 offset = vec2(0.,j * pixelSize.y);
        weight = gaussian(offset);
        s += texture2D(tex, coord + offset * BLOOM_STRENGTH).rgb * weight;
        s += texture2D(tex, coord - offset * BLOOM_STRENGTH).rgb * weight;
        t += weight * 2.0;
    }
    s /= t;

    return s;
}

vec3 bloom(in sampler2D spec, in sampler2D col, in vec2 coord, vec3 color) {
    vec3 base = blur(spec, coord);
    vec3 c = blur(col, coord);

    c *= BLOOM_THRESHOLD;
    base += c;

    float brightness = dot(base, vec3(0.2126, 0.7152, 0.0722));
    brightness = pow(brightness, 4.0);

    #ifdef ENABLE_SPECULAR
        return color + base * brightness;
    #else
        return color + c * brightness;
    #endif
}
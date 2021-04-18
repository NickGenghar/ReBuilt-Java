uniform float viewWidth, viewHeight;

float gaussian(vec2 i, float sigma) {
    return 1.0 / (2.0 * pi * (sigma * sigma)) * exp(-(((i.x * i.x) + (i.y * i.y)) / (2.0 * (sigma * sigma))));
}

vec3 blur(in sampler2D tex, in vec2 coord, in int sampleSize, in float strength, in float intensity) {
    vec3 s = vec3(0.0);
    vec2 pixelSize = vec2(1.0) / vec2(viewWidth, viewHeight);
    float t = 0.0;
    float weight;
    float sigma = float(sampleSize) * intensity;

    for(int j = -sampleSize; j <= sampleSize; j++) {
        for(int i = -sampleSize; i <= sampleSize; i++) {
            vec2 offset = vec2(i * pixelSize.x, j * pixelSize.y) * strength;
            weight = gaussian(offset, sigma);
            s += texture2D(tex, coord + offset).rgb * weight;
            s += texture2D(tex, coord - offset).rgb * weight;
            t += weight * 2.0;
        }
    }
    s /= t;

    return s;
}

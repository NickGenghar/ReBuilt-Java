float bayer(vec2 a, in int samples) {
    float b = 0.0;
    for(int i = 0; i < samples; ++i) {
        a=floor(a);
        b=fract(dot(a, vec2(0.5, a.y*0.75)));

        a*=1.0/float(samples);
        b*=1.0/float(samples);
    }

    return b;
}
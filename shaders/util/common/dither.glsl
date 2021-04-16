float bayer(vec2 a, in int samples) {
    float b = 0.0;
    for(int i = 0; i < samples; ++i) {
        a = floor(a);
        vec2 x = a;
        float y = 1./float(samples);
        b += fract(dot(x*y, vec2(.5,x.y*y*.75))) * (y/2.) + fract(dot(a, vec2(.5,a.y*.75)));
    }

    return b;
}
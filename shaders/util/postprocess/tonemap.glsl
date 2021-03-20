#define TONEMAP_OPERATOR ReColor //Tonemap operators by Nick Genghar. ReColor: ReBuilt style. GBias: UltraMax style. SmoothStep: UltraMin style. [ReColor GBias SmoothStep]

vec3 GBias(vec3 x) {
	float A = 0.6;
	float B = 0.4;
	float C = 0.8;
	float D = 0.65;
	float E = 0.9;
	float F = 1.2;

	vec3 film = vec3(0.7, 0.3, 0.0);
	vec3 colorize = vec3(0.7, 0.3, 0.0);

	float newFilm = dot(film, film * x);
	vec3 newColor = colorize * newFilm;

	x = x * (x + newColor);
	x = clamp(x, 0.0, 1.0);
	x *= 3.0;

	return -((x * ((A + B) / (x + C)) + D) / (x * (A / B) + (A * E))) + F;
}

vec3 ReColor(vec3 x) {
	x.r *= 1.15, x.g *= 1.1, x.b *= 0.97;
	return max(7.*x/5.-2.*x*x/5.*x,x);
}

vec3 SmoothStep(vec3 x) {
	return smoothstep(0., 1., x);
}
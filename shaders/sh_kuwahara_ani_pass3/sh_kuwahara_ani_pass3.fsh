#define PI 3.14159265358979323846

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

float gaussian(float sigma, float pos) { return (1.0 / sqrt(2.0 * PI * sigma * sigma)) * exp(-(pos * pos) / (2.0 * sigma * sigma)); }
        
void main() {
	vec2 tx = 1. / dimension;
	int   kernelRadius = 5;
	float kernelSum    = 0.0;
	
	vec4 col = vec4(0.);
	
	for (int y = -kernelRadius; y <= kernelRadius; ++y) {
		vec4 c = texture2D(gm_BaseTexture, v_vTexcoord + vec2(0., y) * tx);
		float gauss = gaussian(2.0, float(y));
		
		col += c * gauss;
		kernelSum += gauss;
	}
	
	vec3 g = col.rgb / kernelSum;
	
	float lambda1 = 0.5 * (g.y + g.x + sqrt(g.y * g.y - 2.0 * g.x * g.y + g.x * g.x + 4.0 * g.z * g.z));
	float lambda2 = 0.5 * (g.y + g.x - sqrt(g.y * g.y - 2.0 * g.x * g.y + g.x * g.x + 4.0 * g.z * g.z));
	
	vec2 v = vec2(lambda1 - g.x, -g.z);
	vec2 t = length(v) > 0.0 ? normalize(v) : vec2(0.0, 1.0);
	float phi = -atan(t.y, t.x);
	
	float A = (lambda1 + lambda2 > 0.0) ? (lambda1 - lambda2) / (lambda1 + lambda2) : 0.0;
	
	gl_FragColor = vec4(t, phi, A);
}
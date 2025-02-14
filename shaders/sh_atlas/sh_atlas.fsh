varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

#define TAU 6.283185307179586
#define distance_sample 32.

void main() {
	vec2 tx  = 1. / dimension;
	vec2 px  = v_vTexcoord * dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = col;
	
	if(col.a == 1.)
		return;
	
	bool samp = false;
	float angular_sample = distance_sample * TAU * 2.;
	
	for(float i = 1.; i <= distance_sample; i++) {
		float base = 1.;
		float top  = 0.;
		float minDist = 9999.;
		
		for(float j = 0.; j <= angular_sample; j++) {
			float ang = j / angular_sample * TAU;
			
			vec2  pxs = floor(px + vec2( cos(ang),  sin(ang)) * i) + 0.5;
			vec2  txs = pxs * tx;
			vec4  sam = texture2D( gm_BaseTexture, txs );
			float dst = distance(px, pxs);
			
			if(sam.a < 1. || dst > minDist) continue;
			
			gl_FragColor = sam;
			// gl_FragColor = vec4(vec3(i / distance_sample), 1.);
			minDist = dst;
			
			samp = true;
		}
		
		if(samp) return;
	}
}

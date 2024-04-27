varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;

#define TAU 6.283185307179586
#define distance_sample 64.

void main() {
	vec2 tx  = 1. / dimension;
	vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
    gl_FragColor = col;
	
	if(col.a == 1.)
		return;
	
	for(float i = 1.; i <= distance_sample; i++) {
		float base = 1.;
		float top  = 0.;
		
		for(float j = 0.; j <= 128.; j++) {
			float ang = top / base * TAU;
			top += 2.;
			if(top >= base) {
				top = 1.;
				base *= 2.;
			}
			
			vec2  pxs = v_vTexcoord + vec2( cos(ang),  sin(ang)) * i * tx;
			vec4  sam = texture2D( gm_BaseTexture, pxs );
				
			if(sam.a < 1.) continue;
			
			gl_FragColor = sam;
			return;
		}
	}
}

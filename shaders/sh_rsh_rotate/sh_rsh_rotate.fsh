//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;

#define PI 3.14159265359

vec4 sample( vec2 pos ) {
	if(pos.x < 0. || pos.y < 0.) return vec4(0.);
	if(pos.x > 1. || pos.y > 1.) return vec4(0.);
	
	return texture2D( gm_BaseTexture, pos );
}

void main() {
	vec2 tx = 1. / dimension;
	//vec4 a  = sample( v_vTexcoord );
	//gl_FragColor = a;
	//if(a.a == 1.) return;
	
	float dist = length(v_vTexcoord - vec2(0.5, 0.5)) * 3.;
	float cir  = PI * dist * dimension.x;
	
	for( float i = 0.; i < cir; i++ ) {
		float angle = 2. * PI * i / cir;
		vec4 b = sample( vec2(0.5, 0.5) + vec2(cos(angle), sin(angle)) * dist * 0.5 );
		if(b.a == 1.) {
			gl_FragColor = b;
			return;
		}
	}
}

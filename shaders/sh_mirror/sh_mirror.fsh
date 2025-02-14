varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586
#define PI  3.141592653589793

uniform vec2  dimension;
uniform vec2  position;
uniform float angle;

void main() {
	vec2  ps = v_vTexcoord;
	vec2  px = v_vTexcoord * dimension - position;
	float _angle;
	
	_angle = atan(px.y, px.x) + angle;
	_angle = TAU - (_angle - floor(_angle / TAU) * TAU); 
	
	if(_angle < PI) {
		float _alpha    = (angle + PI) - (_angle + angle);
		float inv_angle = (angle + PI) + _alpha;
		float dist      = length(px);
		
		ps = (position + vec2(cos(inv_angle) * dist, -sin(inv_angle) * dist )) / dimension;
	} 
	
	gl_FragColor = vec4(0.);
	if(ps.x > 0. && ps.x < 1. && ps.y > 0. && ps.y < 1.)
		gl_FragColor = texture2D( gm_BaseTexture, ps );
}

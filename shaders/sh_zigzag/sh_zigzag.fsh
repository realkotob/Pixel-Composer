//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 position;
uniform float amount;
uniform int blend;

uniform vec4 col1, col2;

void main() {
	vec2 pos = v_vTexcoord - position;
	float _cell  = 1. / (amount * 2.);
	
    float _xind  = floor(pos.x / _cell);
    float _yind  = floor(pos.y / _cell);
	
    float _xcell = fract(pos.x * amount * 2.);
    float _ycell = fract(pos.y * amount * 2.);
	
	float _x = _xcell;
	float _y = _ycell;
	
	if(mod(_xind, 2.) == 1.)
		_x = 1. - _xcell;
	
	if(blend == 0) {
		if(mod(_yind, 2.) == 1.) {
			if(_x > _y)	gl_FragColor = vec4(col1.rgb, 1.);
			else		gl_FragColor = vec4(col2.rgb, 1.);
		} else {
			if(_x > _y) gl_FragColor = vec4(col2.rgb, 1.);
			else		gl_FragColor = vec4(col1.rgb, 1.);
		}
	} else {
		if(_x > _y) gl_FragColor = vec4(mix(col1.rgb, col2.rgb, _y + (1. - _x)), 1.);
		else		gl_FragColor = vec4(mix(col1.rgb, col2.rgb, _y - _x), 1.);
	}
}

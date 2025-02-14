varying vec2 v_vTexcoord;	
varying vec4 v_vColour;

uniform int   drawLayer;
uniform int   eraser;
uniform vec4  channels;
uniform vec4  pickColor;
uniform float alpha;

uniform sampler2D back;
uniform sampler2D fore;

void main() {
	vec4 bc = texture2D( back, v_vTexcoord );
	vec4 fc = texture2D( fore, v_vTexcoord );
	
	fc   *= channels;
	fc.a *= alpha;
	
	if(eraser == 1) {
		bc -= fc;
		gl_FragColor = bc;
		return;
	}
	
	gl_FragColor = bc;
	
	if(drawLayer == 1) {
		vec4 temp = fc;
		fc = bc;
		bc = temp;
	}
	
	if(drawLayer == 2) {
		if(bc != pickColor) return;
	}
	
	float al = fc.a + bc.a * (1. - fc.a);
	vec4 res = ((fc * fc.a) + (bc * bc.a * (1. - fc.a))) / al;
	res.a = al;
	
	gl_FragColor = res;
}

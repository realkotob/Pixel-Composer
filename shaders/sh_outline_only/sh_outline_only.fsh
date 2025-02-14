//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform float borderSize;
uniform vec4  borderColor;

#define TAU 6.283185307179586

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	
	if(point.a == 0.0) {
		for(float i = 1.; i < 16.; i++) {
			if(i > borderSize) {
				break;
			}
			
			float base = 1.;
			float top  = 0.;
			for(float j = 0.; j <= 64.; j++) {
				float ang = top / base * TAU;
				top += 2.;
				if(top >= base) {
					top = 1.;
					base *= 2.;
				}
		
				vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
				if(pxs.x < 0. || pxs.y < 0. || pxs.x > 1. || pxs.y > 1.) 
					continue;
					
				vec4 sam = v_vColour * texture2D( gm_BaseTexture, pxs );
				if(sam.a > 0.) {
					gl_FragColor = borderColor;
					break;
				}
			}
		}
	} else {
		gl_FragColor = borderColor;
	}
}

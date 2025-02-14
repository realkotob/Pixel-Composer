//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform float hue;
uniform float sat;

uniform int usePalette;
uniform vec4 palette[PALETTE_LIMIT];
uniform int paletteAmount;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
	vec3 _rgb = hsv2rgb(vec3(hue, sat, 1. - v_vTexcoord.y)); 
	
	vec4 color = vec4(_rgb.r, _rgb.g, _rgb.b, v_vColour.a);
	
	if(usePalette == 1) {
		int index = 0;
		float minDist = 999.;
		for(int i = 0; i < paletteAmount; i++) {
			float dist = distance(color.rgb, palette[i].rgb);
			
			if(dist < minDist) {
				minDist = dist;
				index = i;
			}
		}
		
		color = palette[index];
	}
	
    gl_FragColor = color;
}
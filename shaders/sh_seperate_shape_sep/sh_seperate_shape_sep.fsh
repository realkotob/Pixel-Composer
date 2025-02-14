varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D original;
uniform vec4 color;

uniform int override;
uniform vec4 overColor;

void main() {
    vec4 col = texture2D( gm_BaseTexture, v_vTexcoord );
	
	gl_FragColor = vec4(0.);
	
	if(distance(col, color) < 1.)
		gl_FragColor = override == 1? overColor : texture2D( original, v_vTexcoord );
	
}

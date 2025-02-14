varying vec4 v_vColour;
varying vec2 v_vPosition;

uniform sampler2D texture;
uniform sampler2D textureBack;
uniform vec2  dimension;
uniform vec2  fr_flipPos;
uniform vec2  fr_flipSize;
uniform int   hasBack;
uniform int   axis;
uniform int   flip;

void main() {
	vec2 flSiz = fr_flipSize / dimension;
	vec2 flPos = fr_flipPos  / dimension;
	vec2 pos   = v_vPosition;
	
	if(flip == 1) {
		if(axis == 0) pos.y = 1. - pos.y;
		if(axis == 1) pos.x = 1. - pos.x;
	}
	
	vec2 coord = flPos + pos * flSiz;
	vec4 col;
	
	if(hasBack == 1 && flip == 1) col = texture2D( textureBack, coord );
	else						  col = texture2D( texture,     coord );
	
    gl_FragColor = col;
}
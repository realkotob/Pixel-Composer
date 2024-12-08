//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
//////////////// 55 Tile Right ////////////////

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform vec4 crop;
uniform int edge;
uniform int fullEdge;
uniform int extendEdge;

void main() {
	float  w = dimension.x;
	float  h = dimension.y;
	
	vec2  tx = v_vTexcoord * dimension;
	gl_FragColor = vec4(0.);
	
	if(edge == 104 || edge == 64 || edge == 72) {
		if(fullEdge == 0 && tx.x < h - tx.y) discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1])  discard;
		
	} else if(edge == 41 || edge == 66 || edge == 75 || edge == 106 || edge == 74) {
		
	} else if(edge == 11 || edge == 2 || edge == 10) {
		if(fullEdge == 0 && tx.x < tx.y)        discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else if(edge == 8 || edge == 0) {
		if(fullEdge == 0 && tx.x < h - tx.y)    discard;
		if(fullEdge == 0 && tx.x < tx.y)        discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y < crop[1])     discard;
		//if(fullEdge == 1 && extendEdge == 0 && tx.y > h - crop[3]) discard;
		
	} else {
		bool draw = false;
		
		if(edge == 80 || edge == 120 || edge == 86 || edge == 127 || edge == 82 || edge == 123 || edge == 88 || edge == 95 || edge == 126 || edge == 122 || edge == 94 || edge == 91 || edge == 90) {
			if(fullEdge == 0 && tx.x - crop[0] <= tx.y - crop[3])
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.y > h - crop[3]))
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		} 
		
		if(edge == 210 || edge == 251 || edge == 18 || edge == 27 || edge == 82 || edge == 123 || edge == 219 || edge == 250 || edge == 218 || edge == 122 || edge == 26 || edge == 91 || edge == 90) {
			if(fullEdge == 0 && tx.x - crop[0] < h - tx.y - crop[3])
				draw = true;
				
			//if(fullEdge == 1 && (extendEdge == 1 || tx.y < crop[1]))
			//	draw = true;
			if(fullEdge == 1)
				draw = true;
		}
		
		if(!draw) discard;
	}
	
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
}


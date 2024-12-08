//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
    v_vTexcoord = in_TextureCoord;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec4 targetColor;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
	
	if(targetColor.a == 0.) gl_FragColor = c.a == 0.? vec4(1., 0., 0., 1.) : vec4(0.);
	else                    gl_FragColor = targetColor == c? vec4(1., 0., 0., 1.) : vec4(0.);
}


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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform float size;
#define TAU 6.283185307179586

void main() {
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 point = texture2D( gm_BaseTexture, v_vTexcoord );
	float tau_div = TAU / 64.;
	gl_FragColor = point;
	
	if(point.a < 1.) {
		for(float i = 1.; i < size; i++) {
			for(float j = 0.; j < 64.; j++) {
				float ang = j * tau_div;
				vec2 pxs = (pixelPosition + vec2( cos(ang) * i,  sin(ang) * i)) / dimension;
				if(pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.) continue;
				
				vec4 sam = texture2D( gm_BaseTexture, pxs );
				if(sam.a > 0.) {
					gl_FragColor = vec4(sam.rgb, 1.);
					i = size;
					break;
				}
			}
		}
	}
}



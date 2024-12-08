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

uniform vec2  dimension;
uniform float radius;
uniform int   use_8bit;
	
void main() {
	vec3 current = texture2D( gm_BaseTexture, v_vTexcoord ).rgb;
	if(length(current) == 0.) {
		gl_FragColor = vec4(0.);
		return;
	}
	
	vec2  tx = 1. / dimension;
	vec3  sampled = vec3(0.);
	float weight = 0.;
	
	for(float i = -radius; i <= radius; i++)
	for(float j = -radius; j <= radius; j++) {
		vec2 pos = v_vTexcoord + vec2(i, j) * tx;
		if(pos.x < 0. || pos.y < 0. || pos.x > 1. || pos.y > 1.)
			continue;
		
		float str = 1. - length(vec2(i, j)) / radius;
		if(str < 0.) continue;
		
		vec3 _sample = texture2D( gm_BaseTexture, pos ).rgb;
		if(length(_sample) == 0.) 
			continue;
		
		sampled += _sample * str;
		weight  += str;
	}
	
    gl_FragColor = vec4(sampled / weight, 1.);
	
	if(use_8bit == 1) {
		gl_FragColor = gl_FragColor / 256.;
	}
}


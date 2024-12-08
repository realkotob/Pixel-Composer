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
#pragma use(sampler_simple)


    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }


varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  horizontal;

uniform float weight[128];
uniform int	  size;
uniform float angle;

uniform int  overrideColor;
uniform vec4 overColor;

uniform int  gamma;

float wgh = 0.;

vec4 sample(in vec2 pos, in int index) {
	vec4 col = sampleTexture( gm_BaseTexture, pos );
	if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
	
	col.rgb *= weight[index] * col.a;
	wgh     += weight[index] * col.a;
	
	return col;
}

void main() {
    vec2 tex_offset = 1.0 / dimension, pos;
    vec4 result     = sample( v_vTexcoord, 0 );
    mat2 rot        = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	
    if(horizontal == 1) {
        for(int i = 1; i < size; i++) {
			pos = rot * vec2(tex_offset.x * float(i), 0.0);
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    } else {
        for(int i = 1; i < size; i++) {
			pos = rot * vec2(0.0, tex_offset.y * float(i));
			
			result += sample( v_vTexcoord + pos, i );
			result += sample( v_vTexcoord - pos, i );
        }
    }
	
	result.rgb /=  wgh;
	result.a    =  wgh;
	
	if(gamma == 1) result.rgb = pow(result.rgb, vec3(1. / 2.2));
	
	gl_FragColor = result;
	if(overrideColor == 1) {
		gl_FragColor.rgb = overColor.rgb;
		gl_FragColor.a  *= overColor.a;
	}
}



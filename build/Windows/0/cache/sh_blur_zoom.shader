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

uniform vec2  center;
uniform int   blurMode;
uniform int   gamma;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform int useMask;
uniform sampler2D mask;


	#define PARAM_COUNT 1
	uniform int       parameter_active[PARAM_COUNT];
	uniform sampler2D parameters;

	float sampleParameter(in int index, in float def) {
		if(parameter_active[index] == 0) return def;
		float row  = floor(float(index) / 4.);
		vec2 coord = (v_vTexcoord + vec2(float(index) - row * 4., row)) * 0.25;
		vec4 col = texture2D( parameters, coord );
		
		float _val = col.r;
		float _min = col.g * 256. - 128.;
		float _max = col.b * 256. - 128.;
		
		return mix(_min, _max, _val);
	}


float sampleMask() { 
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
} 

void main() { 
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
    vec2 uv = v_vTexcoord - center;
	
	float _str         = sampleParameter(0, str) * sampleMask();
	float nsamples     = 64.;
	float scale_factor = _str * (1. / (nsamples * 2. - 1.));
	vec4  color        = vec4(0.0);
    float blrStart     = 0.;
	
	if(blurMode == 0)		blrStart = 0.;
	else if(blurMode == 1)	blrStart = -nsamples;
	else if(blurMode == 2)	blrStart = -nsamples * 2. - 1.;
	
    for(float i = 0.; i < nsamples * 2. + 1.; i++) {
        float scale = 1.0 + ((blrStart + i) * scale_factor);
		vec2 pos    = uv * scale + center;
		
		vec4 col = sampleTexture( gm_BaseTexture, pos );
		if(gamma == 1) col.rgb = pow(col.rgb, vec3(2.2));
		color += col;
    }
    
    color /= nsamples * 2. + 1.;
    if(gamma == 1) color.rgb = pow(color.rgb, vec3(1. / 2.2));
    
	gl_FragColor = color;
} 


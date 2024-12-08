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

uniform float size;
uniform float spread;

uniform vec2      direction;
uniform int       directionUseSurf;
uniform sampler2D directionSurf;

uniform vec2      strength;
uniform int       strengthUseSurf;
uniform sampler2D strengthSurf;

uniform vec2 dimension;
uniform int	 alpha;
uniform int	 modulateStr;
uniform int	 inv;
uniform int	 blend;
uniform int	 normalized;

vec4 smear(vec2 shift) {
	float delta  = 1. / size;
	
	vec4  base = sampleTexture( gm_BaseTexture, v_vTexcoord );
	float mBri = (base.r + base.g + base.b) / 3. * base.a;
    vec4  res, col, rcol;
	float bright, rbright, dist = 0.;
	
	if(inv == 0) {
		res  = base;
		
		for(float i = 0.; i <= 1.0; i += delta) {
			col = sampleTexture( gm_BaseTexture, v_vTexcoord - shift * i);
			
			if(modulateStr != 2) {
				if(alpha == 0) col.rgb *= 1. - i;
				else           col.a   *= 1. - i;
			}
				  
			bright = (col.r + col.g + col.b) / 3. * col.a;
			
			if(bright > mBri) {
				mBri = bright;
				res  = col;
			}
		}
		
		if(modulateStr == 1) {
			if(alpha == 0) res.rgb *= mBri;
			else           res.a   *= res.a;
		}
		
	} else if(inv == 1) {
		base = alpha == 0? vec4(0., 0., 0., 1.) : vec4(0.);
		mBri = 0.;
	    res  = base;
		
		for(float i = 0.; i <= 1.; i += delta) {
			col    = sampleTexture( gm_BaseTexture, v_vTexcoord + shift * i);
			bright = (col.r + col.g + col.b) / 3. * col.a;
			
			if(bright == 0.) continue;
			if(i > bright)   continue;
			
			if(modulateStr != 2) {
				if(alpha == 0) col.rgb *= i;
				else           col.a   *= i;
			}
			
			mBri   = bright;
			
			float _i = normalized == 1? i / bright : i;
			res    = alpha == 0? vec4(vec3(_i), 1.) : vec4(vec3(1.), _i);
		}
	}
	
    return res;
}

void main() {
	float str = strength.x;
	if(strengthUseSurf == 1) {
		vec4 _vMap = texture2D( strengthSurf, v_vTexcoord );
		str = mix(strength.x, strength.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	float dir = direction.x;
	if(directionUseSurf == 1) {
		vec4 _vMap = texture2D( directionSurf, v_vTexcoord );
		dir = mix(direction.x, direction.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec4 col = vec4(0.);
	
	for(float i = -spread; i <= spread; i++) {
		float r    = radians(dir + 90. + i);
		vec2  dirr = vec2(sin(r), cos(r)) * str;
		vec4  smr  = smear(dirr);
		
			 if(blend == 0) col  = max(col, smr);
		else if(blend == 1) col += smr;
	}
	
    gl_FragColor = col;
}


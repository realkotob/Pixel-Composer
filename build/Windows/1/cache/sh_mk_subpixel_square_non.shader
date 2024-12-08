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
#define TAU 6.28318530718

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D texture;
uniform vec2  dimension;
uniform float seed;
uniform float scale;
uniform float size;
uniform float blur;
uniform float noise;
uniform float intensity;

#define TAU 6.28318530718
uniform int   ridgeUse;
uniform float ridgeCount;
uniform float ridgeIntens;

float random (in vec2 st, float seed) { return fract(sin(dot(st.xy + seed, vec2(1892.9898, 78.23453))) * 437.54123); }

float index(vec2 id) {
	if(id.x > 0.5) return 2.;
    if(id.y < 0.6) return 1.;
    return 0.;
}

float fnoise(vec2 pos, float siz, float dist) {
	float lig = smoothstep(siz, siz + blur, dist);
	float rin = smoothstep(blur, 1. + blur, dist);
    float rnd = random(pos, seed);
    rnd = .5 + (rnd - .5) * 4.;
    lig = mix(lig, lig * rnd, noise * (1. - rin));
    
    return lig;
}

////////////////////////////////////////////////////////////////////////////////////////////////

uniform int   flickerUse;
uniform float flickerIntens;
uniform float flickerCut;
uniform float flickerTime;

float flick(vec2 id) {
	if(flickerUse == 0) return 1.;
    
	float dl = flickerTime + random(id, seed) * TAU;
	float ww = .8 * abs(sin(dl)) + 
	           .2 * sin((dl + random(id, seed + 12.41)) * 2.) + 
	           .1 * sin((dl + random(id, seed + 65.35)) * 3.);
	ww = smoothstep(flickerCut, 1., ww);
	return 1. - ww * flickerIntens;
}

////////////////////////////////////////////////////////////////////////////////////////////////

void main() {
    vec2 scs  = vec2(scale) * 2.;
    vec2 pos  = v_vTexcoord - .5;
         pos *= scs;
    
    vec2 id = floor(pos);
    vec2 px = pos - id;
    vec2 uv = id / scs + .5;
    
    float siz  = 1. - size;
    float ind  = index(px);
    int   indx = int(mod(ind, 3.));
    
    float sz   = siz * .1;
	vec2  cn   = vec2(.5);
	vec2  dn   = vec2(0.);
	
    	 if(indx == 0) { cn = vec2(.25 + sz, .80 - sz); dn = (px - cn) / vec2(1., 0.8); }
    else if(indx == 1) { cn = vec2(.25 + sz, .30 + sz); dn = (px - cn) / vec2(1., 1.2); }
    else if(indx == 2) { cn = vec2(.75 - sz, .50);      dn = (px - cn) / vec2(1., 2.0); }
    
    float dist = 1. - pow(pow(dn.x, 6.) + pow(dn.y, 6.), 1. / 6.) * 4.;
    float lig  = fnoise(pos, siz, dist);
    
    if(ridgeUse == 1) {
	    float ridge = smoothstep(.0, ridgeIntens, pow(abs(sin(px.x * TAU * ridgeCount)), 2.)); 
	    lig = mix(lig, lig * ridge, 1.);
    }
    
    float ints = intensity * flick(id);
    vec3 clr = vec3(0.);
         if(indx == 0) clr.r = ints;
    else if(indx == 1) clr.g = ints;
    else if(indx == 2) clr.b = ints;
    clr *= lig;
    
    vec3 baseC = texture2D( gm_BaseTexture, uv ).rgb;
    baseC.rgb *= clr;
    
    gl_FragColor = vec4(baseC, 1.);
    
    // gl_FragColor = vec4(px, 0., 1.);
}


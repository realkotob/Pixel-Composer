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
#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int  paletteSize;
uniform vec4 palette[PALETTE_LIMIT];
uniform vec2 positions[PALETTE_LIMIT];

uniform float influence;
uniform float progress;

void main() {
    vec4 c = texture2D( gm_BaseTexture, v_vTexcoord );
    if(c.a > 0.) {
        gl_FragColor = c;
        return;
    }
    
    vec4 cc = vec4(0.);
    float w = 0.;
    float minDist = 999.;
    
    for(int i = 0; i < paletteSize; i++) {
        vec4 pal = palette[i];
        vec2 pos = positions[i] / dimension;
        
        if(v_vTexcoord == pos) {
            gl_FragColor = pal;
            return;
        }
        
        float dist = distance(v_vTexcoord, pos);
        minDist = min(minDist, dist);
        
        dist = 1. / pow(dist, influence);
        
        cc += pal * dist;
        w  += dist;
    }
    
    if(w > 0.) cc /= w;
    
    if(progress < 1.) 
        cc.a *= smoothstep(progress * 1.5, progress * 0.5, minDist);
    
    gl_FragColor = cc;
}


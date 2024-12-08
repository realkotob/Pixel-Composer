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

uniform vec2 dimension;
uniform sampler2D surfaceMax;
uniform sampler2D surfaceMin;

vec4 sample(sampler2D tex, vec2 pos) { return texture2D( tex, clamp(pos, 0., 1.) ); }

void main() {
    vec2 tx = 1. / dimension;
    
    vec4 cMax = vec4(0.);
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(0., 0.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(1., 0.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(0., 1.) * tx ));
         cMax = max(cMax, sample( surfaceMax, v_vTexcoord + vec2(1., 1.) * tx ));
    
    vec4 cMin = vec4(1.);
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(0., 0.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(1., 0.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(0., 1.) * tx ));
         cMin = min(cMin, sample( surfaceMax, v_vTexcoord + vec2(1., 1.) * tx ));
    
    gl_FragData[0] = cMax;
    gl_FragData[1] = cMin;
}


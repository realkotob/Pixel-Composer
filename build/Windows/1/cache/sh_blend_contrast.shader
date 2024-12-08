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
//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 dimension;
uniform int tile_type;

uniform int useMask;
uniform int preserveAlpha;
uniform sampler2D mask;
uniform sampler2D fore;
uniform float opacity;

float sampleMask() {
	if(useMask == 0) return 1.;
	vec4 m = texture2D( mask, v_vTexcoord );
	return (m.r + m.g + m.b) / 3. * m.a;
}

void main() {
	vec4 _col0 = texture2D( gm_BaseTexture, v_vTexcoord );
	
	vec2 fore_tex = v_vTexcoord;
	if(tile_type == 0) {
		fore_tex = v_vTexcoord;
	} else if(tile_type == 1) {
		fore_tex = fract(v_vTexcoord * dimension);
	}
	
	vec4 _col1 = texture2D( fore, fore_tex );
	_col1.a *= opacity * sampleMask();
	
	float lum = dot(_col1.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec4 blend = lum > 0.5? (vec4(1.) - (vec4(1.) - _col0) * (vec4(1.) - _col1) * 2.) : (_col0 * _col1 * 2.);
	
	float po = preserveAlpha == 1? _col1.a : opacity;
	vec4 res = mix(_col0, blend, po);
	
	if(preserveAlpha == 1) res.a = _col0.a;
	
    gl_FragColor = res;
}


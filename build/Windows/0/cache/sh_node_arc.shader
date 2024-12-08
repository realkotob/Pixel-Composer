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

uniform vec4  color;
uniform float angle;
uniform vec2  amount;

float sdArc( in vec2 p, in float tb, in float ra, float rb ) {
    vec2 sc = vec2(sin(tb), cos(tb));
    p.x = abs(p.x);
	
    return ((sc.y*p.x>sc.x*p.y) ? length(p-sc*ra) : 
                                  abs(length(p)-ra)) - rb;
}

void main() {
	vec2  p = v_vTexcoord - .5;
	      p *= mat2(cos(angle), -sin(angle), sin(angle), cos(angle)) * 1.5;
	
	float dist = 1. - sdArc(p, .6, .5, 0.) * 2. - 0.4;
	float a;
	vec4  c = vec4(0.);
	
	a = smoothstep(amount.x, amount.y, dist);
	c = mix(c, color, a);
	
	gl_FragColor = c;
}


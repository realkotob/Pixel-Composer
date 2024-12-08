//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
//attribute vec3 in_Normal;                  // (x,y,z)     unused in this shader.
attribute vec4 in_Colour;                    // (r,g,b,a)

varying vec4 v_vColour;

void main() {
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    v_vColour = in_Colour;
}

//######################_==_YOYO_SHADER_MARKER_==_######################@~
varying vec4 v_vColour;

float random (in vec2 st) { return fract(sin(dot(st.xy + vec2(21.456, 46.856), vec2(12.989, 78.233))) * 43758.545); }

void main() {
	float grey = (v_vColour.r + v_vColour.g + v_vColour.b) / 3. * v_vColour.a;
    gl_FragColor = vec4(vec3(1.), grey);
}


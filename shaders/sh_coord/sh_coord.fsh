varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
    gl_FragColor = vec4( v_vTexcoord, 0., 1. );
}

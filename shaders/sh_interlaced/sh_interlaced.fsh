varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int       useSurf;
uniform sampler2D prevFrame;

uniform vec2  dimension;
uniform int   axis;
uniform int   invert;
uniform float size;

void main() {
    vec2 px  = v_vTexcoord * dimension - .5;
         px /= size;
    vec2 md = mod(px, 2.);
    if(invert == 1)
        md = 1. - md;
        
    gl_FragColor = vec4(0.);
    if((axis == 0 && md.y < 1.) || (axis == 1 && md.x < 1.))
        gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
    else if(useSurf == 1)
        gl_FragColor = texture2D( prevFrame, v_vTexcoord );
}

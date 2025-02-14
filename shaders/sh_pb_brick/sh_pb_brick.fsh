//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  scale;
uniform int   axis;
uniform float shift;

uniform float dissolve;
uniform vec2  dissolveSca;
uniform int   dissolveItr;

///////////////////// PERLIN START /////////////////////

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123); }

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f * f * (3.0 - 2.0 * f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float perlin ( vec2 pos, int iteration ) {
	float amp = pow(2., float(iteration) - 1.)  / (pow(2., float(iteration)) - 1.);
    float n = 0.;
	
	for(int i = 0; i < iteration; i++) {
		n += noise(pos) * amp;
		
		amp *= .5;
		pos *= 2.;
	}
	
	return n;
}

///////////////////// PERLIN END /////////////////////

void main() {
	gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord );
	if(gl_FragColor.a == 0.) return;
	
	vec2  px = v_vTexcoord * dimension;
	float _x = px.x;
	float _y = px.y;
	
	if(axis == 1) {
		float _z = _x;
		_x = _y;
		_y = _z;
	}
	
	vec2 sca = scale + 1.;
	
	float rowInd = floor(_y / sca.y);
	float rowPos = _y - rowInd * sca.y;
	
	if(rowPos > scale.y) return;
	
	if(mod(rowInd, 2.) >= 1.)
		_x += shift;
	
	float colInd = floor(_x / sca.x);
	float colPos = _x - colInd * sca.x;
	
	if(colPos > scale.x) return;
	
	if(dissolve > 0. && perlin( vec2( colInd, rowInd ) / dissolveSca, dissolveItr ) <= dissolve )
		return;
		
	gl_FragColor = v_vColour;
}

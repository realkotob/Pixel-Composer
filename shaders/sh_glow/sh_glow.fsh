#define TAU 6.283185307179586

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform int   mode;
uniform float border;
uniform float size;
uniform float strength;
uniform vec4  color;

uniform int   side;
uniform int   render;

float bright(in vec4 col) { return dot(col.rgb, vec3(0.2126, 0.7152, 0.0722)) * col.a; }
vec4  sample(vec2    pos) { return texture2D( gm_BaseTexture, pos ); }

float round(float val) { return fract(val) > 0.5? ceil(val) : floor(val); }
vec2  round(vec2  val) { return vec2(round(val.x), round(val.y)); }

void main() {
	vec2 tx   = 1. / dimension;
	vec2 px   = round(v_vTexcoord * dimension);
	vec4 base = sample(v_vTexcoord);
	
	if(render == 1) {
		gl_FragColor = base;
	} else {
		if(mode == 0) gl_FragColor = vec4(0., 0., 0., 1.);
		if(mode == 1) gl_FragColor = vec4(0., 0., 0., 0.);
	}
	
	if(side == 0) {
		if(mode == 0 && base.rgb == vec3(1.)) return;
		if(mode == 1 && base.a == 1.)         return;
		
	} else if(side == 1) {
		if(mode == 0 && base.rgb == vec3(0.)) return;
		if(mode == 1 && base.a == 0.)         return;
		
	}
	
	float dist = 0.;
	float astp = max(64., size * 4.);
	
    for(float i = 1.; i < size; i++)
	for(float j = 0.; j <= astp; j++) {
		
		float angle = j / astp * TAU;
		vec2  smPos = v_vTexcoord + vec2(cos(angle), sin(angle)) * i * tx;
		vec4  samp  = sample(smPos);
		
		if(side == 0) {
			if((mode == 0 && bright(samp) > bright(base)) || (mode == 1 && samp.a > base.a)) {
				dist = i;
				i = size;
				break;
			}
		} else if(side == 1) {
			if((mode == 0 && bright(samp) < bright(base)) || (mode == 1 && samp.a < base.a)) {
				dist = i;
				i = size;
				break;
			}
		}
	}
	
	if(dist > 0.) {
		vec4 cc   = color;
		float str = (1. - dist / size) * strength;
		
		if(mode == 0)      cc.rgb *= str;
		else if(side == 0) cc.a   *= str;
		else if(side == 1) cc.rgb *= str;
		
		if(render == 1)    gl_FragColor = base + cc;
		else if(side == 0) gl_FragColor = cc;
		else if(side == 1) gl_FragColor = base + cc;
	}
}

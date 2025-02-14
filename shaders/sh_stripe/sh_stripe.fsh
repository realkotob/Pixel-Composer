varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define PI 3.14159265359
#ifdef _YY_HLSL11_ 
	#define PALETTE_LIMIT 1024 
#else 
	#define PALETTE_LIMIT 256 
#endif

uniform float seed;
uniform vec2  dimension;
uniform vec2  position;
uniform int   blend;
uniform float progress;

uniform vec2      amount;
uniform int       amountUseSurf;
uniform sampler2D amountSurf;

uniform vec2      angle;
uniform int       angleUseSurf;
uniform sampler2D angleSurf;

uniform vec2      randomAmount;
uniform int       randomAmountUseSurf;
uniform sampler2D randomAmountSurf;

uniform vec2      ratio;
uniform int       ratioUseSurf;
uniform sampler2D ratioSurf;

uniform int   coloring;
uniform vec4  color0;
uniform vec4  color1;

uniform vec4  palette[PALETTE_LIMIT];
uniform int   paletteAmount;

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2oklab(vec3 c) { #region
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	} #endregion
	
	vec3 oklab2rgb(vec3 c) { #region
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	} #endregion

	vec3 oklabMax(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2hsv(vec3 c) { #region
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	} #endregion

	vec3 hsv2rgb(vec3 c) { #region
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	} #endregion

	float hueDist(float a0, float a1, float t) { #region
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	} #endregion

	vec3 hsvMix(vec3 c1, vec3 c2, float t) { #region
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = h.x + hueDist(h1.x, h2.x, t);
		h.y = mix(h1.y, h2.y, t);
		h.z = mix(h1.z, h2.z, t);
	
		return hsv2rgb(h);
	} #endregion

	vec4 gradientEval(in float prog) { #region
		if(gradient_use_map == 1) {
			vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
			return texture2D( gradient_map, samplePos );
		}
	
		vec4 col = vec4(0.);
	
		for(int i = 0; i < GRADIENT_LIMIT; i++) {
			if(gradient_time[i] == prog) {
				col = gradient_color[i];
				break;
			} else if(gradient_time[i] > prog) {
				if(i == 0) 
					col = gradient_color[i];
				else {
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						col = vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						col = gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						col = vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						col = vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						col = vec4(rgbMix(c0, c1, t), a);
				}
				break;
			}
			if(i >= gradient_keys - 1) {
				col = gradient_color[gradient_keys - 1];
				break;
			}
		}
	
		return col;
	} #endregion
	
#endregion //////////////////////////////////// GRADIENT ////////////////////////////////////

float random (in vec2 st) { return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * (seed + 43758.5453123)); }

void main() { #region
	#region params
		float amo = amount.x;
		if(amountUseSurf == 1) {
			vec4 _vMap = texture2D( amountSurf, v_vTexcoord );
			amo = mix(amount.x, amount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float ang = angle.x;
		if(angleUseSurf == 1) {
			vec4 _vMap = texture2D( angleSurf, v_vTexcoord );
			ang = mix(angle.x, angle.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		ang = radians(ang);
		
		float rnd = randomAmount.x;
		if(randomAmountUseSurf == 1) {
			vec4 _vMap = texture2D( randomAmountSurf, v_vTexcoord );
			rnd = mix(randomAmount.x, randomAmount.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
		
		float rat = ratio.x;
		if(ratioUseSurf == 1) {
			vec4 _vMap = texture2D( ratioSurf, v_vTexcoord );
			rat = mix(ratio.x, ratio.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	#endregion
	
	vec2  pos     = v_vTexcoord - position;
	float aspect  = dimension.x / dimension.y;
	float prog    = pos.x * aspect * cos(ang) - pos.y * sin(ang);
    float _a      = 1. / amo;
	
	float slot    = floor(prog / _a);
	float ground  = (slot + (random(vec2(slot + 0.)) * 2. - 1.) * rnd * 0.5 + 0.) * _a;
	float ceiling = (slot + (random(vec2(slot + 1.)) * 2. - 1.) * rnd * 0.5 + 1.) * _a;
	float _s      = fract((prog - ground) / (ceiling - ground) + progress);
	
	if(coloring == 0) {
		if(blend == 0) gl_FragColor = _s > rat? color0 : color1;
		
		else if(blend == 1) { 
			_s = sin(_s * 2. * PI) * 0.5 + 0.5;
			gl_FragColor = mix(color0, color1, _s);
			
		} else if(blend == 2) { 
			float px = 3. / max(dimension.x, dimension.y);
			_s = smoothstep(-px, px, sin(_s * 2. * PI));
			
			gl_FragColor = mix(color0, color1, _s);
		}
		
	} else if(coloring == 1) {
		int ind = int(mod(_s > rat? slot : slot + 1., float(paletteAmount)));
		
		if(blend == 0 || blend == 2)
			gl_FragColor = palette[ind];
		
		else if(blend == 1) { 
			vec4  c0  = _s > rat? palette[ind] : palette[int(mod(float(ind - 1 + paletteAmount), float(paletteAmount)))];
			vec4  c1  = _s > rat? palette[int(mod(float(ind + 1), float(paletteAmount)))] : palette[ind];
			
			gl_FragColor = mix(c0, c1, _s > rat? _s - rat : _s + (1. - rat));
			
		}
		
	} else if(coloring == 2) {
		gl_FragColor = gradientEval(random(vec2(_s > rat? slot : slot + 1.)));
	}
} #endregion

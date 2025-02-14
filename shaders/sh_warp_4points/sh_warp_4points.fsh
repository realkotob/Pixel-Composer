#pragma use(sampler)

#region -- sampler -- [1730686036.7372286]
	uniform int  interpolation;
	uniform vec2 sampleDimension;
	uniform int  sampleMode;

	const float PI = 3.14159265358979323846;
	float sinc ( float x ) { return x == 0.? 1. : sin(x * PI) / (x * PI); }

	vec4 texture2D_bicubic( sampler2D texture, vec2 uv ) {
		uv = uv * sampleDimension + 0.5;
		vec2 iuv = floor( uv );
		vec2 fuv = fract( uv );
		uv = iuv + fuv * fuv * (3.0 - 2.0 * fuv);
		uv = (uv - 0.5) / sampleDimension;
		return texture2D( texture, uv );
	}

	const int RSIN_RADIUS = 1;
	vec4 texture2D_rsin( sampler2D texture, vec2 uv ) {
		vec2 tx = 1.0 / sampleDimension;
		vec2 p  = uv * sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for (int x = -RSIN_RADIUS; x <= RSIN_RADIUS; x++)
		for (int y = -RSIN_RADIUS; y <= RSIN_RADIUS; y++) {
			vec2 sx = vec2(float(x), float(y));
			float a = length(sx) / float(RSIN_RADIUS);
			// if(a > 1.) continue;
			
			vec4 sample = texture2D(texture, uv + sx * tx);
			float w     = sinc(a * PI * tx.x) * sinc(a * PI * tx.y);
			
			col += w * sample;
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	const int LANCZOS_RADIUS = 3;
	float lanczosWeight(float d, float n) { return d == 0.0 ? 1.0 : (d * d < n * n ? sinc(d) * sinc(d / n) : 0.0); }

	vec4 texture2D_lanczos3( sampler2D texture, vec2 uv ) {
		vec2 center = uv - (mod(uv * sampleDimension, 1.0) - 0.5) / sampleDimension;
		vec2 offset = (uv - center) * sampleDimension;
		vec2 tx = 1. / sampleDimension;
		
		vec4  col = vec4(0.);
		float wei = 0.;
		
		for(int x = -LANCZOS_RADIUS; x < LANCZOS_RADIUS; x++)
		for(int y = -LANCZOS_RADIUS; y < LANCZOS_RADIUS; y++) {
			
			float wx = lanczosWeight(float(x) - offset.x, float(LANCZOS_RADIUS));
			float wy = lanczosWeight(float(y) - offset.y, float(LANCZOS_RADIUS));
			float w  = wx * wy;
			
			col += w * texture2D(texture, center + vec2(x, y) * tx);
			wei += w;
		}
		
		col /= wei;
		return col;
	}

	vec4 texture2Dintp( sampler2D texture, vec2 uv ) {
			 if(interpolation <= 2)	return texture2D(          texture, uv );
		else if(interpolation == 3)	return texture2D_bicubic(  texture, uv );
		else if(interpolation == 4)	return texture2D_lanczos3( texture, uv );
		
		return texture2D( texture, uv );
	}

	vec4 sampleTexture( sampler2D texture, vec2 pos) {
		if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
			return texture2Dintp(texture, pos);
		
			 if(sampleMode <= 1) return vec4(0.);
		else if(sampleMode == 2) return texture2Dintp(texture, clamp(pos, 0., 1.));
		else if(sampleMode == 3) return texture2Dintp(texture, fract(pos));
		else if(sampleMode == 4) return vec4(vec3(0.), 1.);
		
		return vec4(0.);
	}
#endregion -- sampler --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 p0;
uniform vec2 p1;
uniform vec2 p2;
uniform vec2 p3;
uniform vec2 dimension;
uniform int  tile;

float unmix( float st, float ed, float val) { return (val - st) / (ed - st); }

// 2 1
// 3 0

void main() {
	float px = v_vTexcoord.x;
	float py = v_vTexcoord.y;
	float u, v;
	vec2 uv;
	
	#region linear interpolation
		if (abs(p3.y - p0.y) < 1. / dimension.y && abs(p2.y - p1.y) < 1. / dimension.y) { // trapezoid edge case
	        float t = (py - p2.y) / (p3.y - p2.y);
		
			u = unmix(mix(p3.x, p2.x, 1. - t), mix(p0.x, p1.x, 1. - t), px);
			v = t;
	        uv = vec2(u, v);
		} else if(abs(p2.x - p3.x) < 1. / dimension.x && abs(p1.x - p0.x) < 1. / dimension.x) { // trapezoid edge case
			float t = (px - p2.x) / (p1.x - p2.x);
		
			u = t;
			v = unmix(mix(p1.y, p2.y, 1. - t), mix(p0.y, p3.y, 1. - t), py);
	        uv = vec2(u, v);
	    } else {
			vec2 A = (p3 - p0) - (p2 - p1);
		    vec2 B = (p0 - p1);
		    vec2 C = (p2 - p1);
		    vec2 D =  p1;
		
			float c1 = (B.y * C.x) + (A.y * D.x) - (B.x * C.y) - (A.x * D.y);
		    float c2 = (B.y * D.x) - (B.x * D.y);

			float _A = (A.y * C.x) - (A.x * C.y);
			float _B = (A.x * py) + c1 - (A.y * px);
			float _C = (B.x * py) + c2 - (B.y * px);

			u =  A == vec2(0.)?        0. : (-_B - sqrt(_B * _B - 4.0 * _A * _C)) / (_A * 2.0);
			v = (u * A.x + B.x) == 0.? 0. : (px - (u * C.x) - D.x) / (u * A.x + B.x);
			uv = vec2(1. - u, v);
		}
	#endregion
	
	if(tile == 1) uv = fract(1. + fract(uv));
	
	if(uv.x >= 0. && uv.y >= 0. && uv.x <= 1. && uv.y <= 1.)
		gl_FragColor = texture2Dintp( gm_BaseTexture, uv );
	else 
		gl_FragColor = vec4(0.);
}
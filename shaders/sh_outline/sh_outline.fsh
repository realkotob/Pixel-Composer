#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

#define TAU 6.283185307179586

uniform vec2  dimension;

uniform int profile;

uniform vec2      borderStart;
uniform int       borderStartUseSurf;
uniform sampler2D borderStartSurf;

uniform vec2      borderSize;
uniform int       borderSizeUseSurf;
uniform sampler2D borderSizeSurf;

uniform vec4  borderColor;
uniform int	  side;
uniform int	  crop_border;
uniform int	  is_aa;
uniform int	  is_blend;
uniform int	  filter[9];

uniform vec2      blend_alpha;
uniform int       blend_alphaUseSurf;
uniform sampler2D blend_alphaSurf;

uniform int outline_only;
uniform int highRes;

vec2 round(in vec2 v) { 
	v.x = fract(v.x) > 0.5? ceil(v.x) : floor(v.x);	
	v.y = fract(v.y) > 0.5? ceil(v.y) : floor(v.y);	
	return v;
}

vec4 blendColor(vec4 base, vec4 colr, float alpha) {
	
	float blend = base.a + colr.a * alpha * (1. - base.a);
	
	vec4 col = (colr * alpha + base * base.a * ( 1. - alpha )) / blend;
	col.a    = base.a + colr.a * alpha;
	
	return col;
}

bool angleFiltered(float angle) {
	float _dg  = mod((degrees(angle) + 360. + ((side == 0)? 180. : 0.)), 360.);
	
	int  _ind = 0;
	
		 if(_dg <= 22.5 + 45. * 0.) _ind = 3;
	else if(_dg <= 22.5 + 45. * 1.) _ind = 0;
	else if(_dg <= 22.5 + 45. * 2.) _ind = 1;
	else if(_dg <= 22.5 + 45. * 3.) _ind = 2;
	else if(_dg <= 22.5 + 45. * 4.) _ind = 5;
	else if(_dg <= 22.5 + 45. * 5.) _ind = 8;
	else if(_dg <= 22.5 + 45. * 6.) _ind = 7;
	else if(_dg <= 22.5 + 45. * 7.) _ind = 6;
	else                            _ind = 3;
	
	return filter[_ind] == 0;
}

bool  isOutline		  = false;
bool  closetCollected = false;
vec4  closetColor     = vec4(0.);
float closetDistance  = 99999.;

void checkPixel(vec2 px, vec2 p) {
	vec2 txs = p / dimension;
	vec2 pxs = floor(p) + 0.5;
	if(side == 0 && crop_border == 1 && (txs.x < 0. || txs.x > 1. || txs.y < 0. || txs.y > 1.)) return;
	
	vec4 sam = sampleTexture( gm_BaseTexture, txs );
	if(side == 0 && sam.a == 1.) return; //inside border,  skip if current pixel is filled
	if(side == 1 && sam.a == 0.) return; //outside border, skip if current pixel is empty
	
	isOutline = true;
	
	float dist = 0.;
	
		 if(profile == 0) dist = distance(px, pxs);
	else if(profile == 1) dist = max(abs(px.x - pxs.x), abs(px.y - pxs.y));
	else if(profile == 2) dist = abs(px.x - pxs.x) + abs(px.y - pxs.y);
	
	if(dist < closetDistance) {
		closetDistance = dist;
		closetColor    = sam;
	}
}

void main() {
	#region params
		float bStr = borderStart.x;
		if(borderStartUseSurf == 1) {
			vec4 _vMap = texture2D( borderStartSurf, v_vTexcoord );
			bStr = mix(borderStart.x, borderStart.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
		float bSiz = borderSize.x;
		if(borderSizeUseSurf == 1) {
			vec4 _vMap = texture2D( borderSizeSurf, v_vTexcoord );
			bSiz = mix(borderSize.x, borderSize.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
		float bld = blend_alpha.x;
		if(blend_alphaUseSurf == 1) {
			vec4 _vMap = texture2D( blend_alphaSurf, v_vTexcoord );
			bld = mix(blend_alpha.x, blend_alpha.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
		}
	
	#endregion
	
	vec2 pixelPosition = v_vTexcoord * dimension;
	vec4 baseColor = texture2D( gm_BaseTexture, v_vTexcoord );
	vec4 col = outline_only == 0? baseColor : vec4(0.);
	gl_FragColor = col;
	
	#region filter out filled ot empty pixel
		bool isBorder = false;
		if(side == 0)      isBorder = baseColor.a > 0.;
		else if(side == 1) isBorder = baseColor.a < 1.;
	
		if(!isBorder) {
			gl_FragColor = col;
			return;
		}
	#endregion
	
	if(bSiz + bStr > 0.) {
		float itr = bStr + bSiz + float(is_aa);
		
		if(profile == 0) {
			float atr = highRes == 1? 256. : 64.;
			
			for(float i = 1.; i <= itr; i++) {
				float base = 1.;
				float top  = 0.;
				
				for(float j = 0.; j <= atr; j++) {
					float ang = top / base * TAU;
					top += 2.;
					if(top >= base) {
						top   = 1.;
						base *= 2.;
					}
					
					if(angleFiltered(ang)) continue;
					
					vec2 pxs = pixelPosition + vec2( cos(ang),  sin(ang)) * i;
					checkPixel(pixelPosition, pxs);
				}
			}
			
		} else if(profile == 1) {
			for(float i = -itr; i <= itr; i++)
			for(float j = -itr; j <= itr; j++) {
				if(i == 0. && j == 0.) continue;
				checkPixel(pixelPosition, pixelPosition + vec2(j, i));
			}
			
		} else if(profile == 2) {
			for(float i = 1.; i <= itr; i++) {
				for(float j = 0.; j < itr; j++) { if(j >= i) break; checkPixel(pixelPosition, pixelPosition + vec2( j, i - j)); }
				for(float j = 0.; j < itr; j++) { if(j >= i) break; checkPixel(pixelPosition, pixelPosition - vec2( j, i - j)); }
				for(float j = 0.; j < itr; j++) { if(j >= i) break; checkPixel(pixelPosition, pixelPosition + vec2(-j, i - j)); }
				for(float j = 0.; j < itr; j++) { if(j >= i) break; checkPixel(pixelPosition, pixelPosition - vec2(-j, i - j)); }
			}
		}
	
	} else {
		closetDistance = 0.;
		
		float tauDiv = TAU / 4.;
		for(float j = 0.; j < 4.; j++) {
			float ang = j * tauDiv;
			if(angleFiltered(ang)) continue;
			
			vec2 pxs = (pixelPosition + vec2( cos(ang),  sin(ang)) ) / dimension;
			if(side == 0 && crop_border == 1 && (pxs.x < 0. || pxs.x > 1. || pxs.y < 0. || pxs.y > 1.)) continue;
			
			vec4 sam = sampleTexture( gm_BaseTexture, pxs );
				
			if((side == 0 && sam.a == 0.) || (side == 1 && sam.a > 0.)) {
				isOutline = true;
				if(!closetCollected) {
					closetCollected = true;
					closetColor = sam;
				}
				break;
			}
		}
	}
	
	if(!isOutline) return;
	
	float _aa = 1.;
	
	if(is_aa == 1) _aa = min(smoothstep(bSiz + bStr + 1., bSiz + bStr, closetDistance), smoothstep(bStr - 1., bStr, closetDistance));
	else           _aa = min(step(-(bSiz + bStr + 0.5), -closetDistance), step(bStr - 0.5, closetDistance));
	
	if(_aa == 0.) return;
	
	if(is_blend == 0) col = blendColor(baseColor, borderColor, _aa);
	else {
		col = blendColor(side == 0? baseColor : closetColor, borderColor, _aa * bld);
		col.a = _aa;
	}
	
    gl_FragColor = col;
}
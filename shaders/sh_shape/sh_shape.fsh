//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform int  shape;
uniform int  bg;
uniform int  aa;
uniform int  sides;
uniform int  drawDF;

uniform float  angle;
uniform float  inner;
uniform float  corner;

uniform vec2 angle_range;

uniform vec2 dimension;
uniform vec2 center;
uniform vec2 scale;

uniform vec4 bgColor;

#define PI  3.14159265359
#define TAU 6.28318530718

float sdRegularPolygon(in vec2 p, in float r, in int n, in float ang ) {
    // these 4 lines can be precomputed for a given shape
    float an = PI / float(n);
    vec2  acs = vec2(cos(an), sin(an));

    // reduce to first sector
    float bn = mod(atan(p.x, p.y) + PI - ang, 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));

    // line sdf
    p -= r * acs;
    p.y += clamp( -p.y, 0.0, r * acs.y);
    return length(p) * sign(p.x);
}

// signed distance to a n-star polygon with external angle en
float sdStar(in vec2 p, in float r, in int n, in float m, in float ang) { // m=[2,n]
    // these 4 lines can be precomputed for a given shape
    float an = PI / float(n);
    float en = PI / m;
    vec2  acs = vec2(cos(an), sin(an));
    vec2  ecs = vec2(cos(en), sin(en)); // ecs=vec2(0,1) and simplify, for regular polygon,

    // reduce to first sector
    float bn = mod( atan(p.x, p.y) + PI - ang, 2.0 * an) - an;
    p = length(p) * vec2(cos(bn), abs(sin(bn)));

    // line sdf
    p -= r * acs;
    p += ecs * clamp( -dot(p, ecs), 0.0, r * acs.y / ecs.y);
    return length(p)*sign(p.x);
}

// sca is the sin/cos of the orientation
// scb is the sin/cos of the aperture
float sdArc( in vec2 p, in vec2 sca, in vec2 scb, in float ra, in float rb ) {
    p *= mat2(sca.x, sca.y, -sca.y, sca.x);
    p.x = abs(p.x);
    float k = (scb.y * p.x > scb.x * p.y) ? dot(p.xy,scb) : length(p);
    return sqrt( dot(p, p) + ra * ra - 2.0 * ra * k ) - rb;
}

float sdRoundBox( in vec2 p, in vec2 b, in vec4 r )  {
    r.xy = (p.x > 0.0)? r.xy : r.zw;
    r.x  = (p.y > 0.0)? r.x  : r.y;
    vec2 q = abs(p) - b + r.x;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r.x;
}

float sdBox( in vec2 p, in vec2 b ) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void main() {
	float color = 0.;
	vec2 cen = (v_vTexcoord - center) / scale;
	float ratio = dimension.x / dimension.y;
	float d;
	
	if(shape == 0) {
		vec2 edgeDist = abs(cen) - 1.;
		float odist = length(max(edgeDist, 0.));
		float idist = min(max(edgeDist.x, edgeDist.y), 0.);
		d = odist + idist;
	} else if(shape == 1) {
		d = length((v_vTexcoord - center) / scale) - 1.;
	} else if(shape == 2) {
		d = sdRegularPolygon( cen, 0.9 - corner, sides, angle );
		d -= corner;
	} else if(shape == 3) {
	    d = sdStar( cen, 0.9 - corner, sides, 2. + inner * (float(sides) - 2.), angle );
		d -= corner;
	} else if(shape == 4) {
	    d = sdArc( cen, vec2(sin(angle), cos(angle)), angle_range, 0.9 - inner, inner );
		d -= corner;
	} else if(shape == 5) {
		d = sdBox( v_vTexcoord - center, scale - corner);
		d -= corner;
	}
	
	//d = d;
	if(drawDF == 1)
		color = -d;
	else if(aa == 0)
		color = step(d, 0.0);
	else
		color = smoothstep(0.05, 0., d);
	
	gl_FragColor = mix(bgColor, v_vColour, color);
}

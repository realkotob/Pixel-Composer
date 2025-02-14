varying vec2 v_vTexcoord;

uniform float initial_value_pressure;
uniform float max_force;

uniform int  repeat;
uniform int  wall;
uniform vec2 texel_size;

float clampForce(float v) { return clamp(v, -max_force, max_force); }
vec2  clampForce(vec2  v) { return vec2(clampForce(v.x), clampForce(v.y)); }

void main() {
    vec2 right  = clampForce(texture2D(gm_BaseTexture, v_vTexcoord + vec2(texel_size.x, 0.0)).xy) / max_force;
    vec2 left   = clampForce(texture2D(gm_BaseTexture, v_vTexcoord - vec2(texel_size.x, 0.0)).xy) / max_force;
    vec2 bottom = clampForce(texture2D(gm_BaseTexture, v_vTexcoord + vec2(0.0, texel_size.y)).xy) / max_force;
    vec2 top    = clampForce(texture2D(gm_BaseTexture, v_vTexcoord - vec2(0.0, texel_size.y)).xy) / max_force;
    
    gl_FragColor = vec4(initial_value_pressure, (right.x - left.x) + (bottom.y - top.y), 0., 0.);
}

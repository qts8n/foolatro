#ifdef PIXEL
extern number cull_back;
#endif

#ifdef VERTEX
extern vec2 anchor;
extern vec2 sprite_size;
extern number x_rot;
extern number y_rot;
extern number inset;
#endif

extern number fov;

varying vec3 v_p;
varying vec2 v_o;
varying vec3 v_q;

float fov_to_tan(float fov)
{
    return tan(radians(fov) * 0.5);
}


#ifdef VERTEX
vec4 position(mat4 tp, vec4 vert)
{
    vec2 local = (vert.xy - anchor) / sprite_size;
    local *= (1.0 - inset);

    float sin_b = sin(radians(y_rot));
    float cos_b = cos(radians(y_rot));
    float sin_c = sin(radians(x_rot));
    float cos_c = cos(radians(x_rot));

    mat3 rot;
    rot[0] = vec3(cos_b, 0.0, -sin_b);
    rot[1] = vec3(sin_b * sin_c,  cos_c,  cos_b * sin_c);
    rot[2] = vec3(sin_b * cos_c, -sin_c,  cos_b * cos_c);

    float inv_t_half = 0.5 / fov_to_tan(fov);
    vec3 p = rot * vec3(local, inv_t_half);

    float vfac = inv_t_half + 0.5;
    v_p = vec3(p.xy * vfac * rot[2].z, p.z);
    v_o = vfac * rot[2].xy;

    float inv_z = 1.0 / v_p.z;
    v_q = vec3(v_p.xy * inv_z, inv_z);

    vec2 proj = v_q.xy - v_o;
    proj *= sprite_size;
    proj += anchor;

    return tp * vec4(proj, vert.z, 1.0);
}
#endif

#ifdef PIXEL
vec4 effect(vec4 col, Image tex, vec2 uv, vec2 sc)
{
    // Discard back faces
    if (cull_back > 0.5 && v_p.z <= 0.0) discard;

    // Adjust UV for perspective (projective transform)
    float t = fov_to_tan(fov);
    vec2 adj_uv = (v_q.xy / v_q.z - v_o) * t * 2.0;

    vec4 color = Texel(tex, adj_uv + 0.5) * col;
    color.a *= step(max(abs(adj_uv.x), abs(adj_uv.y)), 0.5);

    return color;
}
#endif

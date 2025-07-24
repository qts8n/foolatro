#ifdef PIXEL
extern number cull_back;
extern vec3 light_pos;
extern vec3 light_color;
extern number light_ambient;
extern number light_diffuse;
extern number shininess;
#endif

#ifdef VERTEX
extern vec2 anchor;
extern vec2 sprite_size;
extern vec2 sprite_scale;
extern number x_rot;
extern number y_rot;
extern number inset;
#endif

extern number fov;

varying vec3 v_p;
varying vec2 v_o;
varying vec3 v_q;
varying vec3 v_normal;
varying vec3 v_frag_pos;

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

    vec2 proj = (v_q.xy - v_o) * sprite_size * sprite_scale;
    proj += anchor;

    // Calculate normal based on rotation
    v_normal = rot[2];
    v_frag_pos = vec3(proj, 0.0);

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

    vec4 base_color = Texel(tex, adj_uv + 0.5) * col;
    base_color.a *= step(max(abs(adj_uv.x), abs(adj_uv.y)), 0.5);

    // Calculate lighting
    vec3 normal = normalize(v_normal);
    vec3 light_dir = normalize(light_pos - v_frag_pos);

    // View direction (assuming camera is at 0,0,1 in screen space)
    vec3 view_dir = normalize(vec3(0.0, 0.0, 1.0) - v_frag_pos);

    // Reflection vector
    vec3 reflect_dir = reflect(-light_dir, normal);

    // Calculate specular component
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), shininess);
    vec3 specular = light_color * spec;

    // Calculate diffuse
    float diff = max(dot(normal, light_dir), 0.0);
    vec3 diffuse = light_color * diff * light_diffuse;

    // Calculate ambient
    vec3 ambient = light_color * light_ambient;

    // Combine lighting
    vec3 lighting = ambient + diffuse + specular;

    // Apply lighting to base color
    return vec4(base_color.rgb * lighting, base_color.a);
}
#endif

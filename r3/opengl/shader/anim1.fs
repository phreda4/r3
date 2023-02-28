#version 330 core

uniform sampler2D diffuse_sampler;
uniform sampler2D normal_sampler;
uniform vec3 light_position;
uniform vec3 view_position;

in vec2 v_UV;
in vec3 v_Position;
in mat3 v_TBN;

out vec4 _Color;

void main()
{
    vec3 light_color = vec3(1.f, 1.f, 1.f);
    float abbient_K = 0.6f;
    float specular_K = 0.9f;
    float specular_P = 32f;

    // Ambient.
    vec3 ambient = abbient_K * light_color;
    
    // Diffuse.
    vec3 N = vec3(texture(normal_sampler, v_UV));
    N = N * 2.0 - 1.0;
    N = normalize(v_TBN * N);

    vec3 light_dir = normalize(light_position - v_Position);
    float diff = max(dot(N, light_dir), 0.f);
    vec3 diffuse = diff * light_color;
    
    // Specular.
    vec3 view_dir = normalize(view_position - v_Position);
    vec3 reflect_dir = reflect(-light_dir, N);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.f), specular_P);
    vec3 specular = specular_K * spec * light_color;
    
    vec3 object_color = vec3(texture(diffuse_sampler, v_UV));
    vec3 color = (ambient + diffuse + specular) * object_color;
    _Color = vec4(color, 1.f);
}

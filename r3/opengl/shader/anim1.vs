#version 330 core

layout(location = 0) in vec3 in_Position;
layout(location = 1) in vec3 in_Normal;
layout(location = 2) in vec2 in_UV;
layout(location = 3) in ivec4 in_BoneIds;
layout(location = 4) in vec4 in_Weights;
layout(location = 5) in vec3 in_Tangent;
layout(location = 6) in vec3 in_Bitangent;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

// See kMaxBonesCount.
uniform mat4 bone_transforms[100];

out vec2 v_UV;
out vec3 v_Position;
out mat3 v_TBN;

void main()
{
    mat4 S = mat4(0.f);
    for (int i = 0; i < 4; ++i)
    {
        if (in_BoneIds[i] >= 0)
        {
            S += (bone_transforms[in_BoneIds[i]] * in_Weights[i]);
        }
    }
    mat3 S_ = transpose(inverse(mat3(S)));
    mat4 MVP = projection * view * model;

    gl_Position = MVP * S * vec4(in_Position, 1.f);
    v_UV = in_UV;
    v_Position = vec3(model * vec4(in_Position, 1.f));
    
    vec3 T = normalize(S_ * in_Tangent);
    vec3 B = normalize(S_ * in_Bitangent);
    vec3 N = normalize(S_ * in_Normal);
    v_TBN = mat3(T, B, N);
}
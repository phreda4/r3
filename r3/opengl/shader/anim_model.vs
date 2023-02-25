#version 330 core

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 norm;
layout(location = 2) in vec2 tex;
layout(location = 3) in ivec4 boneIds; 
layout(location = 4) in vec4 weights;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;

const int MAX_BONES = 32;
uniform mat4 finalBonesMatrices[MAX_BONES];

out vec2 TexCoords;

void main()
{
    vec4 totalPosition = vec4(0.0f);
	
	totalPosition += (finalBonesMatrices[boneIds[0]] * vec4(pos,1.0f)) * weights[0];
	totalPosition += (finalBonesMatrices[boneIds[1]] * vec4(pos,1.0f)) * weights[1];
	totalPosition += (finalBonesMatrices[boneIds[2]] * vec4(pos,1.0f)) * weights[2];
	totalPosition += (finalBonesMatrices[boneIds[3]] * vec4(pos,1.0f)) * weights[3];	
	
    mat4 viewModel = view * model;
    gl_Position =  projection * viewModel * totalPosition;
	TexCoords = tex;
}

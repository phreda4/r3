#version 330 core
layout (location = 0) in vec2 aPos;
layout (location = 1) in vec2 uvIn;
out vec2 uv;

uniform mat4 projection;

void main()
{
	gl_Position = projection * vec4(aPos.x, aPos.y, 0.0, 1.0);
	uv = uvIn;
}
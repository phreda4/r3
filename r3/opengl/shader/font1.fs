#version 330 core
in vec2 uv;
uniform sampler2D u_FontTexture;
uniform vec4 fgColor;
out vec4 FragColor;

void main()
{
//	float alpha = texture(u_FontTexture, uv).a;
//	vec4 Fc = vec4(1,1,0.2,1);FragColor = vec4(Fc.rgb, alpha);
	//FragColor = vec4(fgColor.rgb, alpha);
	//FragColor = vec4(1,1,1,1);
	FragColor = texture(u_FontTexture, uv);
}
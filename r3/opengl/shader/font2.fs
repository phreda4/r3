#version 330 core
in vec2 uv;
uniform sampler2D u_FontTexture;
uniform vec4 fgColor;
out vec4 FragColor;

void main()
{
//float alpha = texture(u_FontTexture, uv).a;
//FragColor = vec4(fgColor.rgb, alpha);

FragColor =  fgColor * texture(u_FontTexture, uv);
	
//	vec4 sampled = vec4(1.0, 1.0, 1.0, texture(u_FontTexture, uv).a);
 //   FragColor = vec4(fgColor, 1.0) * sampled;
}
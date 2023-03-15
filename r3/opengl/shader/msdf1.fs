#version 330

in vec2 uv;
out vec4 color;
uniform sampler2D u_FontTexture;
uniform vec4 fgColor;

float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}

void main() {
	vec3 sample = texture( u_FontTexture, uv ).rgb;
	ivec2 sz = textureSize( u_FontTexture, 0 );
	float dx = dFdx( uv.x ) * sz.x;
	float dy = dFdy( uv.y ) * sz.y;
	float toPixels = 8.0 * inversesqrt( dx * dx + dy * dy );
	float sigDist = median( sample.r, sample.g, sample.b );
	float w = fwidth( sigDist );
	float opacity = smoothstep( 0.5 - w, 0.5 + w, sigDist );
	color = fgColor*opacity;
}


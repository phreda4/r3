#version 330

in vec2 uv;
out vec4 color;
uniform sampler2D u_FontTexture;
uniform vec4 fgColor;

float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}

float screenPxRange() {
	vec2 unitRange = vec2(6.0)/vec2(textureSize(u_FontTexture, 0));
	vec2 screenTexSize = vec2(1.0)/fwidth(uv);
	return max(0.5 * dot(unitRange, screenTexSize), 1.0);
}

void main() {
    vec3 msd = texture(u_FontTexture, uv).rgb;
    float sd = median(msd.r, msd.g, msd.b);
    float screenPxDistance = screenPxRange()*(sd - 0.5);
    float opacity = clamp(screenPxDistance + 0.5, 0.0, 1.0);
//    color = vec4(fgColor.rgb, opacity);
	color = fgColor*opacity;
}

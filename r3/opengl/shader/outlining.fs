#version 330


uniform sampler2D u_FontTexture;

in vec2 uv;

float median(float r, float g, float b) {
	return max(min(r, g), min(max(r, g), b));
}

float screenPxRange() {
	vec2 unitRange = vec2(6.0)/vec2(textureSize(u_FontTexture, 0));
	vec2 screenTexSize = vec2(1.0)/fwidth(uv);
	return max(0.5 * dot(unitRange, screenTexSize), 1.0);
}

const vec4 fgColor = vec4(0.1, 0.3, 0.4, 1.0);
const vec4 outlineColor = vec4(0.95, 0.4, 0.3, 1.0);

float thickness = -0.2; // Range: -0.3 < thickness < 0.3
//float outlineThickness = 0.3; // Range: 0.0 < outlineThickness < 0.4
float maxThickness = 0.4 - thickness;

void main() {
	vec4 texel = texture(u_FontTexture, uv);
	float dist = median(texel.r, texel.g, texel.b);
	if (dist <= 0.0001) {
		discard;
	}
	float pxRange = screenPxRange();
	dist -= 0.5 - thickness;
	//float maxPxDist = pxRange/2;
	//float thicknessFactor = maxPxDist * thicknessFactor;
	
  	//float bodyOpacity = clamp(bodyPxDist, 0, 1);
  	float bodyPxDist = pxRange * dist;
  	// Since we have pxDist representing distance in screen
  	// pixels, we can smoothstep between the two closest pixels
  	// to the character border (0.5 to the inside and outside).
	float bodyOpacity = smoothstep(-0.5, 0.5, bodyPxDist);
	
	float outlineThickness = maxThickness * 0.2;

	float charPxDist = pxRange * (dist + outlineThickness);
	float charOpacity = smoothstep(-0.5, 0.5, charPxDist);
	//float charOpacity = clamp(charPxDist + borderDist - outlineThickness, 0.0, 1.0);
	
	float outlineOpacity = charOpacity - bodyOpacity;
	
	vec3 color = mix(outlineColor.rgb, fgColor.rgb, bodyOpacity);
	float alpha = bodyOpacity * fgColor.a + outlineOpacity * outlineColor.a;
	
	gl_FragColor = vec4(color, alpha);
}
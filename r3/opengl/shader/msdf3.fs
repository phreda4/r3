#version 330 core
in vec2 uv;
uniform vec4 fgColor;
out vec4 color;
uniform sampler2D u_FontTexture;

float median(float r, float g, float b) {
    return max(min(r, g), min(max(r, g), b));
}

void main()
{
    vec3 flipped_texCoords = vec3(uv.x, 1.0 - uv.y, uv.z);
    vec2 pos = flipped_texCoords.xy;
    vec3 sample = texture(u_FontTexture, flipped_texCoords).rgb;
    ivec2 sz = textureSize(u_FontTexture, 0).xy;
    float dx = dFdx(pos.x) * sz.x; 
    float dy = dFdy(pos.y) * sz.y;
    float toPixels = 8.0 * inversesqrt(dx * dx + dy * dy);
    float sigDist = median(sample.r, sample.g, sample.b);
    float w = fwidth(sigDist);
    float opacity = smoothstep(0.5 - w, 0.5 + w, sigDist);
    color = vec4(fgColor.rgb, opacity);
}

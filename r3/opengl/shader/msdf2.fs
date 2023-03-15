
vec2 safeNormalize( in vec2 v )
{
   float len = length( v );
   len = ( len > 0.0 ) ? 1.0 / len : 0.0;
   return v * len;
}

void main(void)
{
    // Convert normalized texcoords to absolute texcoords.
    vec2 uv1 = uv * textureSize( u_FontTexture, 0 );
    // Calculate derivates
    vec2 Jdx = dFdx( uv1 );
    vec2 Jdy = dFdy( uv1 );
    // Sample SDF texture (3 channels).
    vec3 sample = texture( u_FontTexture, uv ).rgb;
    // calculate signed distance (in texels).
    float sigDist = median( sample.r, sample.g, sample.b ) - 0.5;
    // For proper anti-aliasing, we need to calculate signed distance in pixels. We do this using derivatives.
    vec2 gradDist = safeNormalize( vec2( dFdx( sigDist ), dFdy( sigDist ) ) );
    vec2 grad = vec2( gradDist.x * Jdx.x + gradDist.y * Jdy.x, gradDist.x * Jdx.y + gradDist.y * Jdy.y );
    // Apply anti-aliasing.
    const float kThickness = 0.125;
    const float kNormalization = kThickness * 0.5 * sqrt( 2.0 );
    float afwidth = min( kNormalization * length( grad ), 0.5 );
    float opacity = smoothstep( 0.0 - afwidth, 0.0 + afwidth, sigDist );
    // Apply pre-multiplied alpha with gamma correction.
    color.a = pow( fgColor.a * opacity, 1.0 / 2.2 );
    color.rgb = fgColor.rgb * color.a;
}

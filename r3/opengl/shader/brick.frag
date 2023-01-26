//
// brick.frag Fragment shader for procedural bricks
// (from "OpenGL Shading Language" book)
//
// Authors: Dave Baldwin, Steve Koren, Randi Rost
//          based on a shader by Darwyn Peachey
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd.
//
// See 3Dlabs-License.txt for license information
//  

uniform vec3 BrickColor, MortarColor;
uniform vec2 BrickSize;
uniform vec2 BrickPct;

varying float LightIntensity;
varying vec2 MCposition;

#define Integral(x, p, notp) ((floor (x) * (p)) + max (fract (x) - (notp), 0.0))

void main (void)
{
  vec3 color;
  vec2 position, useBrick;

  position = MCposition / BrickSize;

  if (fract (position.y * 0.5) > 0.5)
    position.x += 0.5;

#if 0 // non-antialiased bricks
  position = fract (position);

  useBrick = step (position, BrickPct);
#else // antialiased bricks
  // Calculate filter size
  vec2 fw = fwidth (position);

  vec2 MortarPct = vec2 (0.10, 0.15);

  // Perform filtering by integrating the 2D pulse made by
  // the brick pattern over the filter width and height
  useBrick = (Integral (position + fw, BrickPct, MortarPct) -
              Integral (position, BrickPct, MortarPct)) / fw;
#endif

  color  = mix (MortarColor, BrickColor, useBrick.x * useBrick.y);
  color *= LightIntensity;
  gl_FragColor = vec4 (color, 1.0);
}
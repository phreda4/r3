//
// aachecker.frag -- Antialiased checkerboard shader
// (from "OpenGL Shading Language" book)
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd. 
//
// See 3Dlabs-License.txt for license information
//

uniform vec3 Color1;
uniform vec3 Color2;
uniform vec3 AvgColor;
uniform float Frequency;

void main (void)
{
  vec3 color;

  // Determine the width of the projection of one pixel into s-t space
  vec2 fw = fwidth (gl_TexCoord[0].st);
  //vec2 fw = abs (dFdx (gl_TexCoord[0].st))
  //        + abs (dFdy (gl_TexCoord[0].st));

  // Determine the amount of fuzziness
  vec2 fuzz = vec2 (fw * Frequency * 2.0);

  float fuzzMax = max (fuzz.s, fuzz.t);

  // Determine the position in the checkerboard pattern
  vec2 checkPos = fract (gl_TexCoord[0].st * Frequency);

  if (fuzzMax < 0.5)
    {
      // If the filter width is small enough, compute the
      // pattern color
      vec2 p = smoothstep (vec2 (0.5), fuzz + vec2 (0.5), checkPos) +
               (1.0 - smoothstep (vec2 (0.0), fuzz, checkPos));

      color = mix (Color1, Color2, p.x * p.y +
                   (1.0 - p.x) * (1.0 - p.y));

      // Fade in the average color when we get close to the limit
      color = mix (color, AvgColor, smoothstep (0.125, 0.5, fuzzMax));
    }
  else
    {
      // Otherwise, use only the average color
      color = AvgColor;
    }

  gl_FragColor = vec4 (color, 1.0);
}

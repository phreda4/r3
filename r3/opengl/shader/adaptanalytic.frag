//
// adaptanalytic.frag -- Fragment shader for adaptive analytic
// antialiasing
// (from "OpenGL Shading Language" book)
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd. 
//
// See 3Dlabs-License.txt for license information
//

varying float LightIntensity;
varying float V;               // generic varying

uniform float Frequency;       // Stripe frequency = 6

void main (void)
{
  float sawtooth = fract (V * Frequency);
  float triangle = abs (2.0 * sawtooth - 1.0);
  float dp       = length (vec2 (dFdx (V), dFdy (V)));
  float edge     = dp * Frequency * 2.0;
  float square   = smoothstep (0.5 - edge, 0.5 + edge, triangle);

  gl_FragColor = vec4 (vec3 (square), 1.0) * LightIntensity;
}

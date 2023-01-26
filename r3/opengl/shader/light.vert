//
// light.vert -- Vertex shader for lighting
// (from "OpenGL Shading Language" book)
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd. 
//
// See 3Dlabs-License.txt for license information
//

uniform int lightType;

varying vec3 normal;
varying vec3 ecPosition3;
varying vec3 eye;

void main (void)
{
  if ((lightType == 1) || (lightType == 2))
    {
      vec4 ecPosition = gl_ModelViewMatrix * gl_Vertex;
      ecPosition3 = vec3 (ecPosition) / ecPosition.w;
      eye = -normalize (ecPosition3);
    }
  else {
    ecPosition3 = vec3 (0.0);
    eye = vec3 (0.0, 0.0, 1.0);
  }

  normal = normalize (gl_NormalMatrix * gl_Normal);
  gl_Position = ftransform ();
}

//
// lattice.vert -- Vertex shader for lattice
// (from "OpenGL Shading Language" book)
//
// Author: OGLSL implementation by Ian Nurse
//
// Copyright (C) 2002-2005  LightWork Design Ltd.
//          www.lightworkdesign.com
//
// See LightworkDesign-License.txt for license information
//

varying vec3 DiffuseColor;
varying vec3 SpecularColor;

void main (void)
{
  vec3 ecPosition = vec3 (gl_ModelViewMatrix * gl_Vertex);
  vec3 tnorm      = normalize (gl_NormalMatrix * gl_Normal);
  vec3 lightVec   = normalize (vec3 (gl_LightSource[0].position) - ecPosition);
  vec3 viewVec    = normalize (-ecPosition);
  vec3 Hvec       = normalize (viewVec + lightVec);

  float spec = abs (dot (Hvec, tnorm));
  spec = pow (spec, 16.0);

  float Kd        = 0.8;
  vec3 Ambient    = vec3 (gl_FrontMaterial.ambient);
  vec3 LightColor = vec3 (gl_FrontMaterial.diffuse);
  vec3 Specular   = vec3 (gl_FrontMaterial.specular);

  DiffuseColor    = LightColor * vec3 (Kd * abs (dot (lightVec, tnorm)));
  DiffuseColor    = clamp (Ambient + DiffuseColor, 0.0, 1.0);
  SpecularColor   = clamp ((LightColor * Specular * spec), 0.0, 1.0);

  gl_TexCoord[0]  = gl_MultiTexCoord0;
  gl_Position     = ftransform ();
}

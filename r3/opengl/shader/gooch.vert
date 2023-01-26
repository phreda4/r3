//
// gooch.vert -- Vertex shader for gooch matte shading
// (from "OpenGL Shading Language" book)
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd. 
//
// See 3Dlabs-License.txt for license information
//

varying float NdotL;
varying vec3 ReflectVec;
varying vec3 ViewVec;

void main (void)
{
  vec3 ecPos    = vec3 (gl_ModelViewMatrix * gl_Vertex);
  vec3 tnorm    = normalize (gl_NormalMatrix * gl_Normal);
  vec3 lightVec = normalize (vec3 (gl_LightSource[0].position) - ecPos);

  ReflectVec    = normalize (reflect (-lightVec, tnorm));
  ViewVec       = normalize (-ecPos);
  NdotL         = (dot (lightVec, tnorm) + 1.0) * 0.5;
  gl_Position   = ftransform ();
}

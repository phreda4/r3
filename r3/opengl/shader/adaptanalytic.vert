//
// adaptanalytic.vert -- Vertex shader for adaptive analytic
// antialiasing
// (from "OpenGL Shading Language" book)
//
// Copyright (c) 2002-2004 3Dlabs Inc. Ltd. 
//
// See 3Dlabs-License.txt for license information
//

const float SpecularContribution = 0.3;
const float DiffuseContribution  = 1.0 - SpecularContribution;

varying float LightIntensity;
varying float V;

void main (void)
{
  vec3 ecPosition = vec3 (gl_ModelViewMatrix * gl_Vertex);
  vec3 tnorm      = normalize (gl_NormalMatrix * gl_Normal);
  vec3 lightVec   = normalize (vec3 (gl_LightSource[0].position) - ecPosition);
  vec3 reflectVec = reflect (-lightVec, tnorm);
  vec3 viewVec    = normalize (-ecPosition);
  float diffuse   = max (dot (lightVec, tnorm), 0.0);
  float spec      = 0.0;

  if (diffuse > 0.0)
    {
      spec = max (dot (reflectVec, viewVec), 0.0);
      spec = pow (spec, 16.0);
    }

  LightIntensity  = DiffuseContribution * diffuse +
                    SpecularContribution * spec;

  V = gl_MultiTexCoord0.t;

  gl_Position = ftransform ();
}

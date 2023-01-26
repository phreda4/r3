//
// toon.vert -- from lighthouse3d.com
//

varying vec3 normal;
varying vec3 lightDir;

void main (void)
{
  vec3 ecPos = vec3 (gl_ModelViewMatrix * gl_Vertex);
  normal = gl_NormalMatrix * gl_Normal;

  lightDir = normalize (vec3 (gl_LightSource[0].position) - ecPos);

  gl_Position = ftransform ();
}

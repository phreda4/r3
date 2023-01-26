//
// aachecker.vert -- Antialiased checkerboard shader
// from "OpenGL Shading Language"
//

void main (void)
{
  gl_TexCoord[0] = gl_MultiTexCoord0;

  gl_Position = ftransform ();
}

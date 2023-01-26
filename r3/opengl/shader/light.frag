//
// light.frag -- Fragment shader for lighting
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

void DirectionalLight (in int i,
		       in vec3 normal,
		       inout vec4 ambient,
		       inout vec4 diffuse,
		       inout vec4 specular)
{
  float nDotVP; // normal . light direction
  float nDotHV; // normal . light half vector
  float pf;     // power factor

  nDotVP = max (0.0, dot (normal,
		 normalize (vec3 (gl_LightSource[i].position))));
  nDotHV = max (0.0, dot (normal,
		 normalize (vec3 (gl_LightSource[i].halfVector))));

  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow (nDotHV, gl_FrontMaterial.shininess);

  ambient  += gl_LightSource[i].ambient;
  diffuse  += gl_LightSource[i].diffuse * nDotVP;
  specular += gl_LightSource[i].specular * pf;
}


void PointLight (in int i,
		 in vec3 eye,
		 in vec3 ecPosition3,
		 in vec3 normal,
		 inout vec4 ambient,
		 inout vec4 diffuse,
		 inout vec4 specular)
{
  float nDotVP;      // normal . light direction
  float nDotHV;      // normal . light half vector
  float pf;          // power factor
  float attenuation; // computed attenuation factor
  float d;           // distance from surface to light source
  vec3 VP;           // direction from surface to light position
  vec3 halfVector;   // direction of maximum highlights

  // Compute vector from surface to light position
  VP = vec3 (gl_LightSource[i].position) - ecPosition3;

  // Compute distance between surface and light position
  d = length (VP);

  // Normalize the vector from surface to light position
  VP = normalize (VP);

  // Compute attenuation;
  attenuation = 1.0 / (gl_LightSource[i].constantAttenuation +
		       gl_LightSource[i].linearAttenuation * d +
		       gl_LightSource[i].quadraticAttenuation * d * d);

  halfVector = normalize (VP + eye);

  nDotVP = max (0.0, dot (normal, VP));
  nDotHV = max (0.0, dot (normal, halfVector));

  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow (nDotHV, gl_FrontMaterial.shininess);

  ambient  += gl_LightSource[i].ambient;
  diffuse  += gl_LightSource[i].diffuse * nDotVP * attenuation;
  specular += gl_LightSource[i].specular * pf * attenuation;
}


void SpotLight (in int i,
		in vec3 eye,
		in vec3 ecPosition3,
		in vec3 normal,
		inout vec4 ambient,
		inout vec4 diffuse,
		inout vec4 specular)
{
  float nDotVP;          // normal . light direction
  float nDotHV;          // normal . light half vector
  float pf;              // power factor
  float spotDot;         // cosine of angle between spotlight
  float spotAttenuation; // spotlight attenuation factor
  float attenuation;     // computed attenuation factor
  float d;               // distance from surface to light source
  vec3 VP;               // direction from surface to light position
  vec3 halfVector;       // direction of maximum highlights

  // Compute vector from surface to light position
  VP = vec3 (gl_LightSource[i].position) - ecPosition3;

  // Compute distance between surface and light position
  d = length (VP);

  // Normalize the vector from surface to light position
  VP = normalize (VP);

  // Compute attenuation;
  attenuation = 1.0 / (gl_LightSource[i].constantAttenuation +
		       gl_LightSource[i].linearAttenuation * d +
		       gl_LightSource[i].quadraticAttenuation * d * d);

  // See if point on surface is inside cone of illumination
  spotDot = dot (-VP, gl_LightSource[i].spotDirection);

  if (spotDot < gl_LightSource[i].spotCosCutoff)
    spotAttenuation = 0.0; // light adds no contribution
  else
    spotAttenuation = pow (spotDot, gl_LightSource[i].spotExponent);

  // Combine the spotlight and distance attenuation
  attenuation *= spotAttenuation;

  halfVector = normalize (VP + eye);

  nDotVP = max (0.0, dot (normal, VP));
  nDotHV = max (0.0, dot (normal, halfVector));

  if (nDotVP == 0.0)
    pf = 0.0;
  else
    pf = pow (nDotHV, gl_FrontMaterial.shininess);

  ambient  += gl_LightSource[i].ambient;
  diffuse  += gl_LightSource[i].diffuse * nDotVP * attenuation;
  specular += gl_LightSource[i].specular * pf * attenuation;
}


void main (void)
{
  vec4 ambiantLight = vec4 (0.0);
  vec4 diffuseLight = vec4 (0.0);
  vec4 specularLight = vec4 (0.0);

  if (lightType == 0)
    {
      DirectionalLight (0, normal, ambiantLight,
			diffuseLight, specularLight);
    }
  else if (lightType == 1)
    {
      PointLight (0, eye, ecPosition3, normal, ambiantLight,
		  diffuseLight, specularLight);
    }
  else if (lightType == 2)
    {
      SpotLight (0, eye, ecPosition3, normal, ambiantLight,
		 diffuseLight, specularLight);
    }

  vec4 emission = gl_FrontMaterial.emission;
  vec4 ambient  = gl_FrontMaterial.ambient * ambiantLight;
  vec4 diffuse  = gl_FrontMaterial.diffuse * diffuseLight;
  vec4 specular = gl_FrontMaterial.specular * specularLight;

  gl_FragColor  = emission + ambient + diffuse + specular;
}

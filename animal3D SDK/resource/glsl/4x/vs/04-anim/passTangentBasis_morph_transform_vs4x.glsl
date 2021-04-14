/*
	Copyright 2011-2021 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	passTangentBasis_morph_transform_vs4x.glsl
	Calculate and pass morphed tangent basis.
*/

#version 450

#define MAX_OBJECTS 128

// ****TO-DO: 
//	-> declare morph target attributes
//	-> declare and implement morph target interpolation algorithm
//	-> declare interpolation time/param/keyframe uniform
//	-> perform morph target interpolation using correct attributes
//		(hint: results can be stored in local variables named after the 
//		complete tangent basis attributes provided before any changes)

//layout (location = 0) in vec4 aPosition;
//layout (location = 2) in vec3 aNormal;
//layout (location = 8) in vec4 aTexcoord;
//layout (location = 10) in vec3 aTangent;
//layout (location = 11) in vec3 aBitangent;

struct sMorphTarget
{
	vec4 position;	//consumes 1
	vec4 normal;  	//consumes 2
	vec4 tangent;	//consumes 2
};

layout(location = 0) in sMorphTarget aMorphTarget[5];
layout(location = 15) in vec4 aTexcoord;

struct sModelMatrixStack
{
	mat4 modelMat;						// model matrix (object -> world)
	mat4 modelMatInverse;				// model inverse matrix (world -> object)
	mat4 modelMatInverseTranspose;		// model inverse-transpose matrix (object -> world skewed)
	mat4 modelViewMat;					// model-view matrix (object -> viewer)
	mat4 modelViewMatInverse;			// model-view inverse matrix (viewer -> object)
	mat4 modelViewMatInverseTranspose;	// model-view inverse transpose matrix (object -> viewer skewed)
	mat4 modelViewProjectionMat;		// model-view-projection matrix (object -> clip)
	mat4 atlasMat;						// atlas matrix (texture -> cell)
};

uniform ubTransformStack
{
	sModelMatrixStack uModelMatrixStack[MAX_OBJECTS];
};

uniform int uIndex;
uniform float uTime;
uniform mat4 uSize;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
};

flat out int vVertexID;
flat out int vInstanceID;

//https://www.geeks3d.com/20140205/glsl-simple-morph-target-animation-opengl-glslhacker-demo/
//t = morph time - current elapsed time
//spherical linear interpolation
vec4 Slerp(vec4 p0, vec4 p1, float t)
{
  float dotp = dot(normalize(p0), normalize(p1));
  if ((dotp > 0.9999) || (dotp<-0.9999))
  {
    if (t<=0.5)
      return p0;
    return p1;
  }
  float theta = acos(dotp * 3.14159/180.0);
  vec4 P = ((p0*sin((1-t)*theta) + p1*sin(t*theta)) / sin(theta));
  P.w = 1;
  return P;
}

vec4 CubicHermite(vec4 p0, vec4 p1, vec4 tan0, vec4 tan1, float u)
{

    float a = (1 + 2 * u) * pow((1-u),3);
    float b = u * pow((1-u),3);
    float c = pow(u, 2) * (3- 2* u);
    float d = pow(u, 2) * (u - 1);

    return (a * p0 * .5) + (b * tan0 * 3) + (c * p1 *2.8) + (d * tan1 * 3);
}

vec4 sigmoid(vec4 p0, vec4 p1, float param)
{
	float val = (1/ (1 + pow(2.71828, -1 * (param * 10 -5 ))));
	vec4 final  = p1 * val + p0 * (1-val);
	return final;
}

void main()
{
	// DUMMY OUTPUT: directly assign input position to output position
	//gl_Position = aPosition;
	int i = int(uTime) % 5;
	int i2 = (i + 1) % 5;
	float param  = uTime - float(i);	

	vec4 position = sigmoid(aMorphTarget[i].position, aMorphTarget[i2].position, param);
	vec3 normal = Slerp(aMorphTarget[i].normal, aMorphTarget[i2].normal, param).xyz;
	vec3 tangent = Slerp(aMorphTarget[i].tangent, aMorphTarget[i2].tangent, param).xyz;
	vec3 bitangent = cross(normal,tangent);
	
	
	sModelMatrixStack t = uModelMatrixStack[uIndex];
	

	vTangentBasis_view = t.modelViewMatInverseTranspose * mat4(tangent, 0.0, bitangent, 0.0, normal, 0.0, vec4(0.0));
	vTangentBasis_view[3] = t.modelViewMat * position; 
	gl_Position = t.modelViewProjectionMat * position;
	
	vTexcoord_atlas = t.atlasMat * aTexcoord;
 
	//gl_Position = position;


	vVertexID = gl_VertexID;
	vInstanceID = gl_InstanceID;
}

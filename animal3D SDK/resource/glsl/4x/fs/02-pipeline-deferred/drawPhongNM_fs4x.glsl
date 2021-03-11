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
	
	drawPhongNM_fs4x.glsl
	Output Phong shading with normal mapping.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> declare view-space varyings from vertex shader
//	-> declare point light data structure and uniform block
//	-> declare uniform samplers (diffuse, specular & normal maps)
//	-> calculate final normal by transforming normal map sample
//	-> calculate common view vector
//	-> declare lighting sums (diffuse, specular), initialized to zero
//	-> implement loop in main to calculate and accumulate light
//	-> calculate and output final Phong sum



// location of viewer in its own space is the origin
const vec4 kEyePos_view = vec4(0.0, 0.0, 0.0, 1.0);


layout (location = 0) out vec4 rtFragColor;

uniform int uCount;
uniform sampler2D uImage00; // diffuse
uniform sampler2D uImage01; // specular
uniform sampler2D uImage02; // normal
uniform sampler2D uImage03; // height

uniform mat4 uPB_inv;

in vec4 vPosition;
in vec4 vNormal;
in vec4 vTexcoord;
in vec4 vPosition_screen;



struct sPointLight
{
	vec4 pos,worldPos,color, radii;
};

uniform ubLight
{
	sPointLight lightData[MAX_LIGHTS];
};

// declaration of Phong shading model
//	(implementation in "utilCommon_fs4x.glsl")
//		param diffuseColor: resulting diffuse color (function writes value)
//		param specularColor: resulting specular color (function writes value)
//		param eyeVec: unit direction from surface to eye
//		param fragPos: location of fragment in target space
//		param fragNrm: unit normal vector at fragment in target space
//		param fragColor: solid surface color at fragment or of object
//		param lightPos: location of light in target space
//		param lightRadiusInfo: description of light size from struct
//		param lightColor: solid light color
void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);



void main()
{

	vec4 diffuseSample = texture(uImage00, vTexcoord.xy);
	vec4 specularSample = texture(uImage01, vTexcoord.xy);

	//Turn into view space
	vec4 position_view = vPosition_screen;
	position_view /= position_view.w;

	//Fix Normal
	vec4 normal_view =  vNormal; 
	//normal_view = normal_view * 0.5 + 0.5;
	//normal_view =  normalize(normal_view);
	normal_view *= texture(uImage02, vTexcoord.xy);
	normal_view *= 0.1;
	//normal_view -= 0.1;
	normal_view = normalize(normal_view);
	normal_view += 0.0;
	
	

	vec4 diffuseLight = vec4(0.0,0.0,0.0,1.0);
	vec4 specularLight = vec4(0.0,0.0,0.0,1.0);
	for(int i = 0; i < uCount; i++)
	{
	
		vec4 diffuseColor;
		vec4 specularColor;
		calcPhongPoint(diffuseColor, specularColor, normalize( kEyePos_view - vPosition_screen), position_view, normal_view, vec4(1), lightData[i].pos, lightData[i].radii, lightData[i].color);

		diffuseLight += diffuseColor;
		specularLight += specularColor;
	
	}


	rtFragColor = (diffuseSample * diffuseLight) + (specularSample * specularLight);
	rtFragColor.a = diffuseSample.a;

//	rtFragColor = diffuseSample;
//	rtFragColor = specularSample;
//	rtFragColor = vPosition_screen;
//	rtFragColor = normal_view;
//	rtFragColor = vTexcoord;
    rtFragColor = diffuseLight;
	rtFragColor.a = 1;


}

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
	
	postDeferredShading_fs4x.glsl
	Calculate full-screen deferred Phong shading.
*/

#version 450

#define MAX_LIGHTS 1024

// ****TO-DO:
//	-> this one is pretty similar to the forward shading algorithm (Phong NM) 
//		except it happens on a plane, given images of the scene's geometric 
//		data (the "g-buffers"); all of the information about the scene comes 
//		from screen-sized textures, so use the texcoord varying as the UV
//	-> declare point light data structure and uniform block
//	-> declare pertinent samplers with geometry data ("g-buffers")
//	-> use screen-space coord (the inbound UV) to sample g-buffers
//	-> calculate view-space fragment position using depth sample
//		(hint: modify screen-space coord, use appropriate matrix to get it 
//		back to view-space, perspective divide)
//	-> calculate and accumulate final diffuse and specular shading

in vec4 vTexcoord_atlas;

uniform int uCount;
uniform sampler2D uImage00; // diffuse
uniform sampler2D uImage01; // specular
uniform sampler2D uImage04; // scene texcoord
uniform sampler2D uImage05; // normal
uniform sampler2D uImage06; // "position"
uniform sampler2D uImage07; // depth
uniform mat4 uPB_inv;
layout (location = 0) out vec4 rtFragColor;

struct sPointLight
{
	vec4 pos,worldPos,color, radii;
};

uniform ubLight
{
	sPointLight lightData[MAX_LIGHTS];
};

void calcPhongPoint(
	out vec4 diffuseColor, out vec4 specularColor,
	in vec4 eyeVec, in vec4 fragPos, in vec4 fragNrm, in vec4 fragColor,
	in vec4 lightPos, in vec4 lightRadiusInfo, in vec4 lightColor
);

const vec4 kEyePos_view = vec4(0.0, 0.0, 0.0, 1.0);


void main()
{
	
	//code from class
	vec4 screenTexcoord = texture(uImage04, vTexcoord_atlas.xy);
	vec4 diffuseSample = texture(uImage00, screenTexcoord.xy);
	vec4 specularSample = texture(uImage01, screenTexcoord.xy);

	//Turn into screen space
	vec4 position_screen = vTexcoord_atlas;
	position_screen.z = texture(uImage07, vTexcoord_atlas.xy).r;

	//Turn into view space
	vec4 position_view = uPB_inv * position_screen;
	position_view /= position_view.w;

	//Fix Normal
	vec4 normal_view = texture(uImage05, vTexcoord_atlas.xy); 
	//normal_view = (normal_view - 0.5) * 2;
	
	
	//*******//
	

	vec4 diffuseLight = vec4(0.0,0.0,0.0,1.0);
	vec4 specularLight = vec4(0.0,0.0,0.0,1.0);
	for(int i = 0; i < uCount; i++)
	{
	
		vec4 diffuseColor;
		vec4 specularColor;
		calcPhongPoint(diffuseColor, specularColor, normalize(kEyePos_view - position_view), position_view, normal_view, vec4(1), lightData[i].pos, lightData[i].radii, lightData[i].color);

		diffuseLight += diffuseColor;
		specularLight += specularColor;
	
	}


	rtFragColor = (diffuseSample * diffuseLight) + (specularSample * specularLight);
	rtFragColor.a = diffuseSample.a;

//	rtFragColor = diffuseSample;
//	rtFragColor = specularSample;
//	rtFragColor = position_screen;
//	rtFragColor = normal_view;
//	rtFragColor = vTexcoord_atlas;
//	rtFragColor = position_screen;
//	rtFragColor = texture(uImage07, vTexcoord_atlas.xy);
//  rtFragColor = texture(uImage05, vTexcoord_atlas.xy);


}

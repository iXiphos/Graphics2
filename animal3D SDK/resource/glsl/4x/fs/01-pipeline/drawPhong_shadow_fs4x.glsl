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
	
	drawPhong_shadow_fs4x.glsl
	Output Phong shading with shadow mapping.
*/


/*
* 
*    With contributions from Christopher Foster and Aidan Murphy
* 
*/

#version 450

// ****DONE:
// 1) Phong shading
//	-> identical to outcome of last project
// 2) shadow mapping
//	-> declare shadow map texture
//	-> declare shadow coordinate varying
//	-> perform manual "perspective divide" on shadow coordinate
//	-> perform "shadow test" (explained in class)

layout (location = 0) out vec4 rtFragColor;

uniform int uCount;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;
in vec4 shadow_coord;

uniform vec4 uColor;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_shadow;

struct light{
	vec4 lightPos;
	vec4 worldPos;
	vec4 color;
	float radius;
	float radiusSq;
	float radiusInv;
	float radiusInvSq;
};

uniform ubLight
{
	light lightData[4];
};

void main()
{
//Code Found in BlueBook
 vec4 result = vec4(0.0,0.0,0.0,1.0);

	for(int i = 0; i < uCount; i++)
	{
		vec4 L = lightData[i].lightPos - vPosition;
		float dist = length(L);
		L = normalize(L);
		vec4 N = normalize(vNormal);
		vec4 R = reflect (-L, N);
		float NdotR = max(0.0, dot(N, R));
		float NdotL = max(0.0, dot(N, L));


		//Thornton Fernbacher helped us with our attentution Math
		float a = dist/lightData[i].radius * 5;
        float attenuation = 1.0/ ((a*a) + 2);

		vec3 diffuse_color = lightData[i].color.rgb * NdotL * attenuation;
		vec3 specular_color = lightData[i].color.rgb * pow(NdotR, 2) * attenuation;

		
		result  += vec4(diffuse_color + specular_color + vec3(0.1), 0.0) * texture(uTex_dm,vTexcoord);
	}
	
	result = result * texture(uTex_dm,vTexcoord);

//  we think we are on to something with darkening the shadows but are stuck
//	vec4 depthPass = textureProj(uTex_shadow, shadow_coord);
//	vec4 val = step(vec4(0.8), depthPass);

	rtFragColor = result * textureProj(uTex_shadow, shadow_coord);
}


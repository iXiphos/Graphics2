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
	
	drawPhong_fs4x.glsl
	Output Phong shading.

	* With contributions from Christopher Foster and Aidan Murphy
*/

#version 450

// ****DONE: 
//	-> start with list from "drawLambert_fs4x"
//		(hint: can put common stuff in "utilCommon_fs4x" to avoid redundancy)
//	-> calculate view vector, reflection vector and Phong coefficient
//	-> calculate Phong shading model for multiple lights

layout (location = 0) out vec4 rtFragColor;

in vec4 vPosition;
in vec4 vNormal;
in vec2 vTexcoord;

uniform vec4 uLightPos;
uniform float uLightRadii;

uniform vec4 uColor;
uniform vec4 uColor0;
uniform sampler2D uTex_dm;
void main()
{
	// used code from GLSL Blue book as reference


	//  dot product of normal and light vector
	float lightDis = length(uLightPos - vPosition);

	vec4 N = normalize(vNormal);
	vec4 L = normalize((uLightPos  )- vPosition);
	vec4 V = normalize(vPosition);
	vec4 R = reflect(L, N);

	float kd = max(dot(N,L), 0);
	vec4 diffuse_albedo = texture(uTex_dm, vTexcoord) * uColor;
	vec4 diffuse = kd * diffuse_albedo ;
	vec4 specular = pow(max(dot(R, V), 0),  256 * 4 * (1 / lightDis)) * vec4(.9) ;
	
	rtFragColor =  (diffuse + specular) * 0.8 +  diffuse_albedo * 0.2	;
}

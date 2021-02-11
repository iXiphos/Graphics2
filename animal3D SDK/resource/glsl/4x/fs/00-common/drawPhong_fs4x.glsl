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
*/

#version 450

// ****TO-DO: 
//	-> start with list from "drawLambert_fs4x"
//		(hint: can put common stuff in "utilCommon_fs4x" to avoid redundancy)
//	-> calculate view vector, reflection vector and Phong coefficient
//	-> calculate Phong shading model for multiple lights

layout (location = 0) out vec4 rtFragColor;

void main()
{
	vec4 lightPos = vec4(5.0,5.0, 5.0, 0.0);
	//  dot product of normal and light vector
	float lightDis = length(lightPos - vPosition);

	vec4 N = normalize(vNormal);
	vec4 L = normalize(lightPos - vPosition);
	vec4 V = normalize(vPosition);
	vec4 R = reflect(-L, N);

	float kd = max(dot(N,L), 0);
	vec4 diffuse_albedo = texture(uTex_dm, vTexcoord) * uColor;
	vec4 diffuse = kd * diffuse_albedo;
	vec4 specular = pow(max(dot(R, V), 0.0), 128) * vec4(1);
	//specular = vec4(0);

	

	rtFragColor = vec4(0.1, 0.1, 0.1, 0.1) + diffuse + specular + (1 / (1 + (0.5 * pow(lightDis, 2))));
}

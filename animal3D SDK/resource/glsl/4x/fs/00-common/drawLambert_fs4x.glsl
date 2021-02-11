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
	
	drawLambert_fs4x.glsl
	Output Lambertian shading.
*/

#version 450

// ****DONE: 
//	-> declare varyings to receive lighting and shading variables
//	-> declare lighting uniforms
//		(hint: in the render routine, consolidate lighting data 
//		into arrays; read them here as arrays)
//	-> calculate Lambertian coefficient

//	-> implement Lambertian shading model and assign to output
//		(hint: coefficient * attenuation * light color * surface color)
//	-> implement for multiple lights
//		(hint: there is another uniform for light count)

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
	// diffuse coefficient
	//  dot product of normal and light vector


	vec4 N = normalize(vNormal);
	vec4 L = normalize(uLightPos - vPosition);

	float kd = max(dot(L,N), 0);  //diffuse coefficient


	rtFragColor = texture2D(uTex_dm, vTexcoord) * uColor * 1  * clamp(kd, 0.1, 0.5) 
					+ uColor0 * texture2D(uTex_dm, vTexcoord) * 0.3;
}

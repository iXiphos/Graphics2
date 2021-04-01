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
	
	passTangentBasis_displace_tes4x.glsl
	Pass interpolated and displaced tangent basis.
*/

#version 450

// ****TO-DO: 
//	-> declare inbound and outbound varyings to pass along vertex data
//		(hint: inbound matches TCS naming and is still an array)
//		(hint: outbound matches GS/FS naming and is singular)
//	-> copy varying data from input to output
//	-> displace surface along normal using height map, project result
//		(hint: start by testing a "pass-thru" shader that only copies 
//		gl_Position from the previous stage to get the hang of it)

layout (triangles, equal_spacing) in;

out vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vbVertexData_out;

in vbVertexData_tess {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
} vVertexData_tess[];

uniform sampler2D uTex_dm, uTex_sm, uTex_nm, uTex_hm;
uniform mat4 uMVP, uP;

void main()
{
	// gl_TessCoord -> barycentric (3 elements)
	vec2 tc1 = mix(vVertexData_tess[0].vTexcoord_atlas.xy, vVertexData_tess[1].vTexcoord_atlas.xy, gl_TessCoord.x);
	vec2 tc2 = mix(vVertexData_tess[2].vTexcoord_atlas.xy, vVertexData_tess[3].vTexcoord_atlas.xy, gl_TessCoord.x);
	vec2 tc = mix(tc2, tc1, gl_TessCoord.y);

	vbVertexData_out.vTexcoord_atlas = vec4(tc,0,0);
	vec4 p1 = mix(gl_in[0].gl_Position, gl_in[1].gl_Position, gl_TessCoord.x);
	vec4 p2 = mix(gl_in[2].gl_Position, gl_in[3].gl_Position, gl_TessCoord.x);
	vec4 p = mix(p2, p1, gl_TessCoord.y);

	p.y += texture(uTex_dm, tc).r;
	vbVertexData_out.vTangentBasis_view = vVertexData_tess[gl_PrimitiveID].vTangentBasis_view ;

	gl_Position = uMVP * p;
}

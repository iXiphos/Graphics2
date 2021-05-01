Shader "Unlit/Bloom"
{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}

	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex, _SourceTex;
		float4 _MainTex_TexelSize;
		half _Threshold, _SoftThreshold;
		float4 _Color;

		half3 Sample(float2 uv)
		{
			return tex2D(_MainTex, uv).rgb;
		}

		//Gaussian Box Blur
		half3 SampleBox(float2 uv, float delta)
		{
			float4 o = _MainTex_TexelSize.xyxy * float2(-delta, delta).xyxy;
			half3 s =
				Sample(uv + o.xy) + Sample(uv + o.zy) +
				Sample(uv + o.xw) + Sample(uv + o.zw);
			return s * 0.25f;
		}

		//Filter pixels based on light
		half3 Prefilter(half3 c)
		{
			//c = GammaToLinearSpace(c);
			half bright = max(max(c.r, c.g), c.b);
			half knee = _Threshold * _SoftThreshold;
			half soft = bright = (_Threshold - knee);
			soft = clamp(soft, 0, 2 * knee);
			soft = soft * soft * 1 / (4 * knee + 0.00001);

			c *= max(soft, bright - _Threshold) / max(bright, 1e-5);

			return c;
		}

		struct VertexData
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct Interpolators
		{
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

		Interpolators VertexProgram(VertexData v)
		{
			Interpolators i;
			i.pos = UnityObjectToClipPos(v.vertex);
			i.uv = v.uv;
			return i;
		}
	ENDCG

			SubShader{
				Cull Off
				ZTest Always
				ZWrite Off

				Pass { //0
					CGPROGRAM
						#pragma vertex VertexProgram
						#pragma fragment FragmentProgram
						half4 FragmentProgram(Interpolators i) : SV_Target
						{
							return half4(Prefilter(SampleBox(i.uv, 1)), 1);
						}

					ENDCG
				}

				Pass { //1
					Blend One One

					CGPROGRAM
						#pragma vertex VertexProgram
						#pragma fragment FragmentProgram
						half4 FragmentProgram(Interpolators i) : SV_Target
						{
							return half4(SampleBox(i.uv, 0.5), 1);
						}
					ENDCG
				}

				Pass { //2
					CGPROGRAM
						#pragma vertex VertexProgram
						#pragma fragment FragmentProgram
						half4 FragmentProgram(Interpolators i) : SV_Target
						{
							half4 c = tex2D(_SourceTex, i.uv);
							c.rgb += SampleBox(i.uv, 0.5);
							return _Color * c;
						}

					ENDCG
				}
			}

}

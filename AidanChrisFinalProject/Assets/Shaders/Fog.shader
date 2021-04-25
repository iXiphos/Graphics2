Shader "Unlit/Fog"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        
        _Gloss("Gloss", Range(0, 1)) = 1.0
        _FogHeight("Fog Height",Range(-100,2000)) = 1.0
        _FogColor("Fog Color", Color) = (1,1,1,1)
        _FogMaxDistance("Fog Max Distance", Range(50,5000)) = 10
        _FogYDepth("Y Depth", Range(0,5000)) = 200
        _FogStregnth("Stregnth", Range(0,1)) = 1
        _FogEnabled("Enabled", Range(0,1)) = 1

   

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100


        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityShaderVariables.cginc"


            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float depth : DEPTH;
                float3 normal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color;
            float _Gloss;
            float _FogHeight;
            float4 _FogColor;
            float _FogMaxDistance;
            float _FogYDepth;
            float _FogStregnth;
            float _FogEnabled;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.depth = -UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w;
                float3 worldNorm = UnityObjectToWorldNormal(v.normal);
                o.normal = worldNorm; //mul((float3x3)UNITY_MATRIX_V, worldNorm);
                o.worldPos =  mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
           


            fixed4 frag (v2f i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz;
                float3 lambert = saturate( dot(N, L));
                float3 diffuse = saturate( dot(N, L)) * _LightColor0.xyz;

                float3 viewDir = _WorldSpaceCameraPos - i.vertex;
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 H = normalize(L + V);
                float3 specularLight = saturate(dot(H,N) * (lambert > 0));
                float specularExponent = exp2(_Gloss * 11) + 2;
                specularLight = pow(specularLight, specularExponent);
                specularLight *= _LightColor0;
                diffuse = diffuse * tex2D(_MainTex, i.uv) * _Color + float3(0.05,0.05,0.05);


                float depth = 1 - i.depth;
                float YDepth = length(_FogHeight - i.worldPos.y) / _FogYDepth;
                float XZDepth = length(_WorldSpaceCameraPos.xz - i.worldPos.xz)/ _FogMaxDistance;
                
                //animations
                //XZDepth += (sin(_Time * 20) + 1) * 0.01 ;
                


                depth = XZDepth * ((1 - YDepth) + _FogStregnth);
                depth += _FogStregnth;
                
                
                //interpolate on the x and y directions

                if(depth < 0){
                    depth  = 0;
                }
               
                if(depth > 1){
                   depth = 1;
                }


                float3 finalColorWithoutFog = diffuse + specularLight;
                float3 colorWithFog;
                if((int)_FogEnabled){
                    colorWithFog = lerp(finalColorWithoutFog, _FogColor, depth);
                }
                else{
                    colorWithFog = finalColorWithoutFog;
                }

                return float4( colorWithFog, 1);


            }
            ENDCG
        }        
    }
}

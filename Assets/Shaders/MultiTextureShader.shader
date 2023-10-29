Shader "Custom/MultiTextureShader"
{
    Properties
    {
        _MainTex1 ("Texture_1", 2D) = "white" {}
        _MainTex2 ("Texture_2", 2D) = "white" {}
        _Blend ("Blend", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalRenderPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "OwnPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex1_ST;
            float4 _MainTex2_ST;
            float _Blend;
            float _Cut;
            CBUFFER_END

            //TEXTURE2D(_MainTex1);
            sampler2D _MainTex1;
            //TEXTURE2D(_MainTex2);
            sampler2D _MainTex2;
            
            Varyings vert (const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = input.uv;

                return output;
            }

            float4 frag (const Varyings input) : SV_Target
            {
                float4 texture1 = tex2D(_MainTex1, input.uv);
                float4 texture2 = tex2D(_MainTex2, input.uv);
                float4 col = lerp(texture1, texture2, _Blend > input.uv.x * _MainTex1_ST.x);
                return col;
            }
            
            ENDHLSL
        }

        Pass
            {
                Name "Depth"
                Tags { "LightMode" = "DepthOnly" }
                
                Cull Back
                ZTest LEqual
                ZWrite On
                ColorMask R
                
                HLSLPROGRAM
                
                #pragma vertex DepthVert
                #pragma fragment DepthFrag
                 // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
                 #include "Common/DepthOnly.hlsl"
                 ENDHLSL
            }

            Pass
            {
                Name "Normals"
                Tags { "LightMode" = "DepthNormalsOnly" }
                
                Cull Back
                ZTest LEqual
                ZWrite On
                
                HLSLPROGRAM
                
                #pragma vertex DepthNormalsVert
                #pragma fragment DepthNormalsFrag

                #include "Common/DepthNormalsOnly.hlsl"
                
                ENDHLSL
            }
    }
}

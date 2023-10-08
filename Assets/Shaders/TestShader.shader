Shader "Custom/TestShader"
{
    Properties 
    {
        //_Color("Color", Color) = (1, 1, 1, 1)
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
            
            
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half3 normal : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.normal = TransformObjectToWorldNormal(input.normalOS);
                
                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                half4 color = 0;
                color.rgb = input.normal;
                return color;
            }
            ENDHLSL
        }
    }
}
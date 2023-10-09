Shader "Custom/TestShader"
{
    Properties 
    {
        [KeywordEnum(Red, Green, Blue, Black)]
        _ColorKeyword("Color", Float) = 0
        [KeywordEnum(Object, World, View)]
        _SpaceKeyword("Space", Float) = 0
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

            #pragma shader_feature_local_fragment _COLORKEYWORD_RED _COLORKEYWORD_GREEN _COLORKEYWORD_BLUE _COLORKEYWORD_BLACK
            #pragma shader_feature_local _SPACEKEYWORD_OBJECT _SPACEKEYWORD_WORLD _SPACEKEYWORD_VIEW

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END


            Varyings Vert(const Attributes input)
            {
                Varyings output;

                /*#if _SPACEKEYWORD_OBJECT
                output.positionHCS = TransformObjectToHClip(input.positionOS + float3(0, 1, 0));
                #elif _SPACEKEYWORD_WORLD
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                #endif*/
                output.positionHCS = TransformObjectToHClip(input.positionOS + float3(0, 1, 0));
                output.positionWS = TransformObjectToWorld(input.positionOS);
                
                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                float4 col = 1;

                #if _COLORKEYWORD_RED
                col = float4(1, 0, 0, 1);
                #elif _COLORKEYWORD_GREEN
                col = float4(0, 1, 0, 1);
                #elif _COLORKEYWORD_BLUE
                col = float4(0, 0, 1, 1);
                #elif _COLORKEYWORD_BLACK
                col = float4(0, 0, 0, 1);
                #endif
                
                return col;
            }
            ENDHLSL
        }
    }
}
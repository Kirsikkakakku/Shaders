Shader "Custom/Intersection"    
{
    Properties
    {
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _SecondaryColor("Intersection Color", Color) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        
        Pass
        {   
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float4 _SecondaryColor;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
            };

            Varyings Vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                return output;
            }

            float4 Frag (Varyings input) : SV_Target
            {
                float2 screenSpaceUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                float4 depthTexture = LinearEyeDepth(SampleSceneDepth(screenSpaceUV), _ZBufferParams);
                float4 depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
                float4 lerpValue = pow(1 - saturate(depthTexture - depthObject), 15);
                return lerp(_Color, _SecondaryColor, lerpValue);
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
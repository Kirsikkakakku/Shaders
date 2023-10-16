Shader "Custom/BlinnPhong"
{
    Properties 
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Float) = 1.0
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
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            HLSLPROGRAM
            
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : NORMAL;
            };

            CBUFFER_START(UnityPErMaterial)
            float4 _Color;
            float _Shininess;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            float4 BlinnPhong(Varyings input)
            {
                Light mainLight = GetMainLight((input.positionHCS));
                float3 ambient = 0.1 * mainLight.color;
                float3 diffuse = saturate(dot(input.normalWS, mainLight.direction)) * mainLight.color;
                float3 viewDir = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 halfDir = normalize(mainLight.direction + viewDir);
                float3 specular = pow(saturate(dot(input.normalWS, halfDir)), _Shininess) * mainLight.color;
                
                return float4((ambient + diffuse + specular) * _Color, 1);
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                return BlinnPhong(input);
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
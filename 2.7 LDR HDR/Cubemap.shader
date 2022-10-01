Shader "Custom/Cubemap"
{
    Properties
    {
        _cubemap ("Cubemap",cube)=""{}
    }
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalRenderPipeline""RenderType"="Opaque"}

        Pass{
        HLSLPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #pragma vertex vert
        #pragma fragment frag

        TEXTURECUBE (_cubemap);
        SAMPLER(sampler_cubemap);

        struct a2v
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float4 vertexLocal : TEXCOORD0;
        };

        v2f vert(a2v v)
        {
            v2f o;
            o.vertexLocal = v.vertex;
            //UnityObjectToClipPos变成TransformObjectToHClip 是Core.hlsl中的函数
            o.pos = TransformObjectToHClip(v.vertex.xyz);
            return o;
        }

        
        

        half4 frag(v2f i):SV_TARGET
        {
            float3 WorldPos = i.pos;
            float4 col = SAMPLE_TEXTURECUBE(_cubemap,sampler_cubemap,normalize(i.vertexLocal));
            return col;
        }
        ENDHLSL
    }
    }
}

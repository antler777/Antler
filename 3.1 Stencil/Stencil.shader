Shader "Custom/Stencil"
{
    Properties
    {
        _MainTex ("MainTexture",2D)="white"{}
        _FlowMap("Flow Map",2D)="black"{}
        _TimeSpeed("Time Speed",float) = 1.0
        _FlowStrength("Flowmap Intensity",range(0,1))=0.1
        
        _Sref ("Stencil Ref",float)=1
        [Enum(UnityEngine.Rendering.CompareFunction)] _Scomp("Stencil Comp",Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _SOP("Stencil Op",Float) = 2

    }
    SubShader
    {
        Tags{"RenderPipeline" = "UniversalRenderPipeline""RenderType"="Opaque"}

        Pass{
            Stencil{
                Ref[_Sref]
                comp[_Scomp]
                Pass[_SOp]
                }
        HLSLPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #pragma vertex vert
        #pragma fragment frag

        TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
        TEXTURE2D(_FlowMap); SAMPLER(sampler_FlowMap);
        float4 _MainTex_ST;
        float _TimeSpeed;
        float _FlowStrength;


        struct a2v
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 texcoord  : TEXCOORD0;
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
        };

        v2f vert(a2v v)
        {
            v2f o;
            o.uv = v.texcoord;
            o.pos = TransformObjectToHClip(v.vertex.xyz);
            return o;
        }

        
        

        half4 frag(v2f i):SV_TARGET
        {
            float2 UV = i.uv*_MainTex_ST.xy+i.uv*_MainTex_ST.zw;
            
            float phase0 = frac(_Time*_TimeSpeed);
            float phase1 = frac(_Time *_TimeSpeed +0.5);
            float3 flowDir =  (SAMPLE_TEXTURE2D(_FlowMap,sampler_FlowMap,UV)*2.0-1.0)*_FlowStrength;//之前没有乘以2减去1
            //用波形函数周期化向量场方向，用偏移后的uv对材质进行偏移采样
            half3 tex0 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,UV-flowDir.xy*phase0);
            half3 tex1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,UV-flowDir.xy*phase1);
            //构造函数计算随波形函数变化的权值，使得MainTex采样值在接近最大偏移时有权值为0，因此消隐
            float flowLerp = abs((0.5-phase0)/0.5);
            half3 finalCol = lerp(tex0,tex1,flowLerp);
            
            return half4(finalCol,1.0);
            
        }
        ENDHLSL
    }
    }
}

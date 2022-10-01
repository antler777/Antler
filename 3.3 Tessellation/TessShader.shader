Shader "Custom/TessShader"
{
    Properties
    {
        _TessellationUniform("TessllationUniform",Range(1,64))=1
    }
    SubShader
    {
        Tags { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
        }
        Pass{

            // Render State

            HLSLPROGRAM
            #pragma require tessellation
            #pragma require geometry

            #pragma vertex BeforeTessVertProgram
            #pragma hull HullProgram
            #pragma domain DomainProgram
            #pragma fragment FragmentProgram

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 4.6

            // Includes
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
            float _TessellationUniform;
            CBUFFER_END
            //顶点着色器输入
            struct Attributes
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent : TANGENT;
            };
            //片段着色器输入
            struct Varyings
            {
                float4 vertex:SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent :TANGENT;
            };
            
            struct TessellationFactors
            {
                //不同的图元该结构会不同
                //该部分用于Hull shader里面
                //定义了patch的属性
                //Tessellation Factor和Inner Tessellation Factor
                float edge[3]:SV_TessFactor;
                float inside :SV_InsideTessFactor;
            };
            //顶点着色器结构的定义
            struct ControlPoint
            {
                float4 vertex: INTERNALTESSPOS;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent :TANGENT;
            };
            
            
            // 顶点着色器
            ControlPoint BeforeTessVertProgram (Attributes v)
            {
                ControlPoint o;
                o.vertex = v.vertex;
                o.uv = v.uv;
                o.tangent = v.tangent;
                o.normal = v.normal;
                return o;
            }

            TessellationFactors hsconst(InputPatch<ControlPoint, 3> patch)
            {
                //定义曲面细分的参数
                TessellationFactors o;
                o.edge[0] = _TessellationUniform;
                o.edge[1] = _TessellationUniform;
                o.edge[2] = _TessellationUniform;
                o.inside = _TessellationUniform;
                return o;
            }
             //细分阶段非常灵活，可以处理三角形，四边形或等值线。我们必须告诉它必须使用什么表面并提供必要的数据。
            //这是 hull 程序的工作。Hull 程序在曲面补丁上运行，该曲面补丁作为参数传递给它。
            //我们必须添加一个InputPatch参数才能实现这一点。Patch是网格顶点的集合。必须指定顶点的数据格式。
            //现在，我们将使用ControlPoint结构。在处理三角形时，每个补丁将包含三个顶点。此数量必须指定为InputPatch的第二个模板参数
            //Hull程序的工作是将所需的顶点数据传递到细分阶段。尽管向其提供了整个补丁，
            //但该函数一次仅应输出一个顶点。补丁中的每个顶点都会调用一次它，并带有一个附加参数，
            //该参数指定应该使用哪个控制点（顶点）。该参数是具有SV_OutputControlPointID语义的无符号整数。
            [domain("tri")]//明确地告诉编译器正在处理三角形，其他选项：
            [outputcontrolpoints(3)]//明确地告诉编译器每个补丁输出三个控制点
            [outputtopology("triangle_cw")]//当GPU创建新三角形时，它需要知道我们是否要按顺时针或逆时针定义它们
            [partitioning("fractional_odd")]//告知GPU应该如何分割补丁，现在，仅使用整数模式
            [patchconstantfunc("hsconst")]//GPU还必须知道应将补丁切成多少部分。这不是一个恒定值，每个补丁可能有所不同。必须提供一个评估此值的函数，称为补丁常数函数（Patch Constant Functions）

            ControlPoint HullProgram(InputPatch<ControlPoint, 3> patch, uint id : SV_OutputControlPointID)
            {
                //定义hullshaderV函数
                return patch[id];
            }
            Varyings AfterTessVertProgram (Attributes v)
			{
				Varyings o;
				o.vertex = TransformObjectToHClip(v.vertex);
				o.uv = v.uv;

                return o;
			}

            [domain("tri")]//Hull着色器和Domain着色器都作用于相同的域，即三角形。我们通过domain属性再次发出信号
            Varyings DomainProgram (TessellationFactors factors, const OutputPatch<ControlPoint,3> patch,float3 bary:SV_DOMAINLOCATION)
            //bary:重心坐标
            {
                Attributes v;
                v.vertex = patch[0].vertex*bary.x + patch[1].vertex*bary.y + patch[2].vertex*bary.z;
                v.tangent = patch[0].tangent*bary.x + patch[1].tangent*bary.y + patch[2].tangent*bary.z;
                v.normal = patch[0].normal*bary.x + patch[1].normal*bary.y + patch[2].normal*bary.z;
                v.uv = patch[0].uv*bary.x + patch[1].uv*bary.y + patch[2].uv*bary.z;
                
                return AfterTessVertProgram (v);
            }
            
            // #endif
            float4 FragmentProgram (Varyings i) : SV_Target
            {
                return float4(1.0,1.0,1.0,1.0);
            }
            ENDHLSL
        }    
    }
}

Shader "Custom/XRay"
{
    Properties
    {
        [NoScaleOffset]_Main_Texture("Main Texture", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        [NoScaleOffset]_Normal_Map("Normal Map", 2D) = "white" {}
        _Texture_Tiling("Texture Tiling", Vector) = (1, 1, 0, 0)
        _Texture_Offset("Texture Offset", Vector) = (0, 0, 0, 0)
        _Size("Size", Float) = 1
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
        _Opacity("Opacity", Range(0, 1)) = 1
        [HideInInspector]_Player_Position("Player Position", Vector) = (0.5, 0.5, 0, 0)
        [HideInInspector]_Player_Distance("Player Distance", Float) = 0
        [HideInInspector]_WorkflowMode("_WorkflowMode", Float) = 1
        [HideInInspector]_CastShadows("_CastShadows", Float) = 1
        [HideInInspector]_ReceiveShadows("_ReceiveShadows", Float) = 1
        [HideInInspector]_Surface("_Surface", Float) = 1
        [HideInInspector]_Blend("_Blend", Float) = 0
        [HideInInspector]_AlphaClip("_AlphaClip", Float) = 1
        [HideInInspector]_BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1
        [HideInInspector]_SrcBlend("_SrcBlend", Float) = 1
        [HideInInspector]_DstBlend("_DstBlend", Float) = 0
        [HideInInspector][ToggleUI]_ZWrite("_ZWrite", Float) = 0
        [HideInInspector]_ZWriteControl("_ZWriteControl", Float) = 1
        [HideInInspector]_ZTest("_ZTest", Float) = 4
        [HideInInspector]_Cull("_Cull", Float) = 2
        [HideInInspector]_AlphaToMask("_AlphaToMask", Float) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
            "DisableBatching"="False"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite On
        AlphaToMask [_AlphaToMask]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
        #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _LIGHT_LAYERS
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma multi_compile_fragment _ _LIGHT_COOKIES
        #pragma multi_compile _ _FORWARD_PLUS
        #pragma multi_compile _ EVALUATE_SH_MIXED EVALUATE_SH_VERTEX
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_FORWARD
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float2 _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2, _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2, _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2);
            float4 _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.tex, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.samplerstate, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2) );
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_R_4_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.r;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_G_5_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.g;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_B_6_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.b;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_A_7_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.a;
            float4 _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4 = _Tint;
            float4 _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4, _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4, _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4);
            UnityTexture2D _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2, _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2, _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2);
            float4 _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.tex, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.samplerstate, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2) );
            _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4);
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_R_4_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.r;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_G_5_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.g;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_B_6_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.b;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_A_7_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.a;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.BaseColor = (_Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4.xyz);
            surface.NormalTS = (_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5018867, 0.5018867, 0.5018867) : SRGBToLinear(float3(0.5018867, 0.5018867, 0.5018867));
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DYNAMICLIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ USE_LEGACY_LIGHTMAPS
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
        #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
        #pragma multi_compile_fragment _ _SHADOWS_SOFT _SHADOWS_SOFT_LOW _SHADOWS_SOFT_MEDIUM _SHADOWS_SOFT_HIGH
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
        #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        #pragma shader_feature_fragment _ _SURFACE_TYPE_TRANSPARENT
        #pragma shader_feature_local_fragment _ _ALPHAPREMULTIPLY_ON
        #pragma shader_feature_local_fragment _ _ALPHAMODULATE_ON
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        #pragma shader_feature_local_fragment _ _SPECULAR_SETUP
        #pragma shader_feature_local _ _RECEIVE_SHADOWS_OFF
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
        #define VARYINGS_NEED_SHADOW_COORD
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_GBUFFER
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ProbeVolumeVariants.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion;
            #endif
             float4 fogFactorAndVertexLight;
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord;
            #endif
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
            #if defined(LIGHTMAP_ON)
             float2 staticLightmapUV : INTERP0;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
             float2 dynamicLightmapUV : INTERP1;
            #endif
            #if !defined(LIGHTMAP_ON)
             float3 sh : INTERP2;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
             float4 probeOcclusion : INTERP3;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
             float4 shadowCoord : INTERP4;
            #endif
             float4 tangentWS : INTERP5;
             float4 texCoord0 : INTERP6;
             float4 fogFactorAndVertexLight : INTERP7;
             float3 positionWS : INTERP8;
             float3 normalWS : INTERP9;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            #if defined(LIGHTMAP_ON)
            output.staticLightmapUV = input.staticLightmapUV;
            #endif
            #if defined(DYNAMICLIGHTMAP_ON)
            output.dynamicLightmapUV = input.dynamicLightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.sh;
            #endif
            #if defined(USE_APV_PROBE_OCCLUSION)
            output.probeOcclusion = input.probeOcclusion;
            #endif
            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            output.shadowCoord = input.shadowCoord;
            #endif
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float2 _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2, _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2, _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2);
            float4 _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.tex, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.samplerstate, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2) );
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_R_4_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.r;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_G_5_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.g;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_B_6_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.b;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_A_7_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.a;
            float4 _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4 = _Tint;
            float4 _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4, _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4, _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4);
            UnityTexture2D _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2, _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2, _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2);
            float4 _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.tex, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.samplerstate, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2) );
            _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4);
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_R_4_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.r;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_G_5_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.g;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_B_6_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.b;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_A_7_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.a;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.BaseColor = (_Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4.xyz);
            surface.NormalTS = (_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = float(0);
            surface.Specular = IsGammaSpace() ? float3(0.5018867, 0.5018867, 0.5018867) : SRGBToLinear(float3(0.5018867, 0.5018867, 0.5018867));
            surface.Smoothness = float(0.5);
            surface.Occlusion = float(1);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
             float3 normalWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "MotionVectors"
            Tags
            {
                "LightMode" = "MotionVectors"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask RG
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 3.5
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_MOTION_VECTORS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/MotionVectorPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        ColorMask R
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }
        
        // Render State
        Cull [_Cull]
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALS
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 TangentSpaceNormal;
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 tangentWS : INTERP0;
             float4 texCoord0 : INTERP1;
             float3 positionWS : INTERP2;
             float3 normalWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.tangentWS.xyzw = input.tangentWS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            output.normalWS.xyz = input.normalWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.tangentWS = input.tangentWS.xyzw;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            output.normalWS = input.normalWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Normal_Map);
            float2 _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_43b91203a5cd44fabdc805e44a87091d_Out_0_Vector2, _Property_4c43f12d846b4d1d8c6e0a4c0a8f7776_Out_0_Vector2, _TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2);
            float4 _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.tex, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.samplerstate, _Property_d7bfba09456b4b238726f7b25afcd848_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_69fd09895e27455b8e7c45733d357e11_Out_3_Vector2) );
            _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.rgb = UnpackNormal(_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4);
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_R_4_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.r;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_G_5_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.g;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_B_6_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.b;
            float _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_A_7_Float = _SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.a;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.NormalTS = (_SampleTexture2D_f29cc3848f344bcab09aa07b4c24fd32_RGBA_0_Vector4.xyz);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature _ EDITOR_VISUALIZATION
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define ATTRIBUTES_NEED_TEXCOORD2
        #define ATTRIBUTES_NEED_INSTANCEID
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD1
        #define VARYINGS_NEED_TEXCOORD2
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_META
        #define _FOG_FRAGMENT 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
             float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
             float4 texCoord1;
             float4 texCoord2;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float4 texCoord1 : INTERP1;
             float4 texCoord2 : INTERP2;
             float3 positionWS : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.texCoord1.xyzw = input.texCoord1;
            output.texCoord2.xyzw = input.texCoord2;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.texCoord1 = input.texCoord1.xyzw;
            output.texCoord2 = input.texCoord2.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float2 _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2, _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2, _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2);
            float4 _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.tex, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.samplerstate, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2) );
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_R_4_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.r;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_G_5_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.g;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_B_6_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.b;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_A_7_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.a;
            float4 _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4 = _Tint;
            float4 _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4, _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4, _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4);
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.BaseColor = (_Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull [_Cull]
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float2 _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2, _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2, _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2);
            float4 _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.tex, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.samplerstate, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2) );
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_R_4_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.r;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_G_5_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.g;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_B_6_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.b;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_A_7_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.a;
            float4 _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4 = _Tint;
            float4 _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4, _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4, _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4);
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.BaseColor = (_Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4.xyz);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "Universal 2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }
        
        // Render State
        Cull [_Cull]
        Blend [_SrcBlend] [_DstBlend]
        ZTest [_ZTest]
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma vertex vert
        #pragma fragment frag
        
        // Keywords
        #pragma shader_feature_local_fragment _ _ALPHATEST_ON
        // GraphKeywords: <None>
        
        // Defines
        
        #define _NORMALMAP 1
        #define _NORMAL_DROPOFF_TS 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX_NORMAL_OUTPUT
        #define FEATURES_GRAPH_VERTEX_TANGENT_OUTPUT
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_2D
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include_with_pragmas "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRenderingKeywords.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/DebugMipmapStreamingMacros.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(ATTRIBUTES_NEED_INSTANCEID)
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float3 WorldSpacePosition;
             float2 NDCPosition;
             float2 PixelPosition;
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0 : INTERP0;
             float3 positionWS : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.texCoord0.xyzw = input.texCoord0;
            output.positionWS.xyz = input.positionWS;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.texCoord0.xyzw;
            output.positionWS = input.positionWS.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED || defined(VARYINGS_NEED_INSTANCEID)
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Main_Texture_TexelSize;
        float4 _Tint;
        float2 _Player_Position;
        float _Size;
        float _Smoothness;
        float _Opacity;
        float4 _Normal_Map_TexelSize;
        float2 _Texture_Tiling;
        float2 _Texture_Offset;
        float _Player_Distance;
        UNITY_TEXTURE_STREAMING_DEBUG_VARS;
        CBUFFER_END
        
        
        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(_Main_Texture);
        SAMPLER(sampler_Main_Texture);
        TEXTURE2D(_Normal_Map);
        SAMPLER(sampler_Normal_Map);
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }
        
        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }
        
        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }
        
        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }
        
        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }
        
        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }
        
        void Unity_Multiply_float_float(float A, float B, out float Out)
        {
            Out = A * B;
        }
        
        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }
        
        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }
        
        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }
        
        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }
        
        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }
        
        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }
        
        void Unity_Lerp_float(float A, float B, float T, out float Out)
        {
            Out = lerp(A, B, T);
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main_Texture);
            float2 _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2 = _Texture_Tiling;
            float2 _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2 = _Texture_Offset;
            float2 _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_f92a8adb66f04bf5a2df8823e4213071_Out_0_Vector2, _Property_5d6c68ec2ee94b608a1d2031259a822b_Out_0_Vector2, _TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2);
            float4 _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.tex, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.samplerstate, _Property_e0ffdab8f7a94d9aaa3580ca111a5c13_Out_0_Texture2D.GetTransformedUV(_TilingAndOffset_b026dad5a9ba48ee9cb751e7d2dc6e56_Out_3_Vector2) );
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_R_4_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.r;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_G_5_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.g;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_B_6_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.b;
            float _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_A_7_Float = _SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4.a;
            float4 _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4 = _Tint;
            float4 _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4;
            Unity_Multiply_float4_float4(_SampleTexture2D_f855e198be8648cfadfef011bf2399fe_RGBA_0_Vector4, _Property_5ca32376427b47c9b16b30e763ef72fe_Out_0_Vector4, _Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4);
            float _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float = _Smoothness;
            float4 _ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
            float2 _Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2 = _Player_Position;
            float2 _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2;
            Unity_Remap_float2(_Property_51578d0d74024946abcc8d30623b9b58_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2);
            float2 _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2;
            Unity_Add_float2((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), _Remap_095c0664f0b54b19999fe3d7491a72e2_Out_3_Vector2, _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2);
            float2 _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2;
            Unity_TilingAndOffset_float((_ScreenPosition_b9d9a5586b364fe6a2e3d33a04c614fc_Out_0_Vector4.xy), float2 (1, 1), _Add_0c8b0026b4d04e16805427f503db8baf_Out_2_Vector2, _TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2);
            float2 _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2;
            Unity_Multiply_float2_float2(_TilingAndOffset_62de35c672af4749bb0c2d7ebd8e56b7_Out_3_Vector2, float2(2, 2), _Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2);
            float2 _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2;
            Unity_Subtract_float2(_Multiply_3b503f4d010e4eb2a5e832ebac6333b2_Out_2_Vector2, float2(1, 1), _Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2);
            float _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float);
            float _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float = _Size;
            float _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float;
            Unity_Multiply_float_float(_Divide_e9857b8c32dc4440ac529732dbffb3dc_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float, _Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float);
            float2 _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2 = float2(_Multiply_e8dec95b1cfc41b5adadd123e021ca46_Out_2_Float, _Property_f1c01dae94d54fe0adba032b8af72b65_Out_0_Float);
            float2 _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2;
            Unity_Divide_float2(_Subtract_e4c2eae35fc447eb9e2869fcdbb2dc51_Out_2_Vector2, _Vector2_b19c1e93fb18482b8b1405c61428ac54_Out_0_Vector2, _Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2);
            float _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float;
            Unity_Length_float2(_Divide_16dea105c65e41e4877e3431b485fef7_Out_2_Vector2, _Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float);
            float _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float;
            Unity_OneMinus_float(_Length_d1016fad9c7d436d8795a8c851627320_Out_1_Float, _OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float);
            float _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float;
            Unity_Saturate_float(_OneMinus_29b6984064c04780af927a935e4f5471_Out_1_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float);
            float _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float;
            Unity_Smoothstep_float(float(0), _Property_8adb321edfc449c1854040fa071bfbb1_Out_0_Float, _Saturate_8c08bef391bf4a7487b4095cd839c97f_Out_1_Float, _Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float);
            float _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float = _Opacity;
            float _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float;
            Unity_Multiply_float_float(_Smoothstep_d668918f5f244d3f810e313b513da424_Out_3_Float, _Property_d382ea76e5e9477b8c999f735c272df7_Out_0_Float, _Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float);
            float _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float;
            Unity_OneMinus_float(_Multiply_c13271605c394920a745d2fd3856990f_Out_2_Float, _OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float);
            float _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float;
            Unity_Distance_float3(IN.WorldSpacePosition, _WorldSpaceCameraPos, _Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float);
            float _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float = _Player_Distance;
            float _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float;
            Unity_Multiply_float_float(_Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float, 0.9, _Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float);
            float2 _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2 = float2(_Multiply_908fc8297f3541d8804e6bf5807e5ad5_Out_2_Float, _Property_8dfe98046aec490db7d34c34def9ae16_Out_0_Float);
            float _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float;
            Unity_Remap_float(_Distance_e0bb7659cf9e4d24bc637927a91485b2_Out_2_Float, _Vector2_595ebcab96b04580be2d257787193ebf_Out_0_Vector2, float2 (0, 1), _Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float);
            float _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float;
            Unity_Clamp_float(_Remap_4d67c708ba1b49e98fb58a1017765f73_Out_3_Float, float(0), float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float);
            float _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            Unity_Lerp_float(_OneMinus_0e87d5fa26f642b58e98a5c4cd2c1d18_Out_1_Float, float(1), _Clamp_9b27be92e6994fe883a47e6e50b31612_Out_3_Float, _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float);
            surface.BaseColor = (_Multiply_e7bb56504572486bafa2da920408b15d_Out_2_Vector4.xyz);
            surface.Alpha = _Lerp_348c838986b8421e9511a489f819ae06_Out_3_Float;
            surface.AlphaClipThreshold = float(0.5);
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
        #if VFX_USE_GRAPH_VALUES
            uint instanceActiveIndex = asuint(UNITY_ACCESS_INSTANCED_PROP(PerInstance, _InstanceActiveIndex));
            /* WARNING: $splice Could not find named fragment 'VFXLoadGraphValues' */
        #endif
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.WorldSpacePosition = input.positionWS;
        
            #if UNITY_UV_STARTS_AT_TOP
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #else
            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScaledScreenParams.y - input.positionCS.y) : input.positionCS.y);
            #endif
        
            output.NDCPosition = output.PixelPosition.xy / _ScaledScreenParams.xy;
            output.NDCPosition.y = 1.0f - output.NDCPosition.y;
        
            output.uv0 = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        #else // TODO: XR support for procedural instancing because in this case UNITY_ANY_INSTANCING_ENABLED is not defined and instanceID is incorrect.
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}
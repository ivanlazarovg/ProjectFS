// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/Grass"
{
	Properties
	{
		_NormalFactor("NormalFactor ", Float) = 0
		_SpecularColor("Specular Color", Color) = (0.3921569,0.3921569,0.3921569,1)
		_Shininess("Shininess", Range( 0.01 , 1)) = 0.1
		_GrassColour("GrassColour", Color) = (1,1,1,1)
		[NoScaleOffset]_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]NoiseTextureFloat("NoiseTexture", 2D) = "white" {}
		_WindStrenght("Wind Strenght", Range( 0 , 2)) = 0.5
		WindStrenghtFloat("WindStrenghtFloat", Range( 0 , 1)) = 0.8
		[Toggle(_WIGGLE_ON)] _Wiggle("Wiggle", Float) = 1
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		_TranslucencyPower("Translucency Power", Float) = 0
		_WiggleStrenght("Wiggle Strenght", Range( 0 , 1)) = 0.5
		_Translucencycolor("Translucency color", Color) = (0,0,0,0)
		_TranslucencyScale("Translucency Scale", Float) = 0
		_LightAtten("Light Atten ", Float) = 0
		_GrassBottomColour("GrassBottomColour", Color) = (1,1,1,0)
		_GrassTipColour("GrassTipColour", Color) = (1,1,1,0)
		_GrassTipStrength("GrassTipStrength", Float) = 0
		_GrassBottomStrength("GrassBottomStrength", Float) = 0
		_Color0("Color 0", Color) = (0,0,0,0)
		_ValueRandom("ValueRandom", Vector) = (1,2,0,0)
		_RootDarkeningFactor("RootDarkeningFactor", Float) = 0
		_RootAmbient("RootAmbient", Float) = 0
		_DarkeningClamp("DarkeningClamp", Float) = 0
		_LighteningClamp("LighteningClamp", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.53
		_Maxold("Max old", Float) = 0
		_DarkerLength("DarkerLength", Float) = 0
		_MinOld("Min Old", Float) = 0
		_MinNew("Min New", Float) = 0
		_MaxNew("Max New", Float) = 0
		_Ambient("Ambient", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma multi_compile __ _WIND_ON
		#pragma multi_compile __ _WIGGLE_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float3 WindDirection;
		uniform sampler2D NoiseTextureFloat;
		uniform float _WindStrenght;
		uniform float WindStrenghtFloat;
		uniform float4 _Color0;
		uniform sampler2D _MainTex;
		uniform float _WiggleStrenght;
		uniform float4 _SpecularColor;
		uniform float _Shininess;
		uniform float4 _GrassBottomColour;
		uniform float _GrassBottomStrength;
		uniform float4 _GrassColour;
		uniform float _DarkerLength;
		uniform float4 _GrassTipColour;
		uniform float _GrassTipStrength;
		uniform float _NormalFactor;
		uniform float _TranslucencyPower;
		uniform float _TranslucencyScale;
		uniform float _MinOld;
		uniform float _Maxold;
		uniform float _MinNew;
		uniform float _MaxNew;
		uniform float _LightAtten;
		uniform float4 _Translucencycolor;
		uniform float4 _Ambient;
		uniform float _RootAmbient;
		uniform float2 _ValueRandom;
		uniform float _DarkeningClamp;
		uniform float _LighteningClamp;
		uniform float _RootDarkeningFactor;
		uniform float _Cutoff = 0.53;


		sampler2D	_TouchReact_Buffer;
		float4 _TouchReact_Pos;
		 
		float3 TouchReactAdjustVertex(float3 pos)
		{
		   float3 worldPos = mul(unity_ObjectToWorld, float4(pos,1));
		   float2 tbPos = saturate((float2(worldPos.x,-worldPos.z) - _TouchReact_Pos.xz)/_TouchReact_Pos.w);
		   float2 touchBend  = tex2Dlod(_TouchReact_Buffer, float4(tbPos,0,0));
		   touchBend.y *= 1.0 - length(tbPos - 0.5) * 2;
		   if(touchBend.y > 0.01)
		   {
		      worldPos.y = min(worldPos.y, touchBend.x * 10000);
		   }
		
		   float3 changedLocalPos = mul(unity_WorldToObject, float4(worldPos,1)).xyz;
		   return changedLocalPos - pos;
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_output_1056_0 = float3( (WindDirection).xz ,  0.0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner1060 = ( 1.0 * _Time.y * ( temp_output_1056_0 * 0.4 * 10.0 ).xy + (ase_worldPos).xz);
			float4 worldNoise1038 = ( tex2Dlod( NoiseTextureFloat, float4( ( ( panner1060 * 0.1 ) / float2( 10,10 ) ), 0, 0.0) ) * _WindStrenght * WindStrenghtFloat );
			float4 transform1029 = mul(unity_WorldToObject,( float4( WindDirection , 0.0 ) * ( v.color.a * worldNoise1038 ) ));
			#ifdef _WIND_ON
				float4 staticSwitch1031 = transform1029;
			#else
				float4 staticSwitch1031 = float4( 0,0,0,0 );
			#endif
			float3 ase_vertex3Pos = v.vertex.xyz;
			v.vertex.xyz += ( staticSwitch1031 + float4( TouchReactAdjustVertex(float4( ase_vertex3Pos , 0.0 ).xyz) , 0.0 ) ).xyz;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float3 temp_output_1056_0 = float3( (WindDirection).xz ,  0.0 );
			float3 ase_worldPos = i.worldPos;
			float2 panner1060 = ( 1.0 * _Time.y * ( temp_output_1056_0 * 0.4 * 10.0 ).xy + (ase_worldPos).xz);
			float4 worldNoise1038 = ( tex2D( NoiseTextureFloat, ( ( panner1060 * 0.1 ) / float2( 10,10 ) ) ) * _WindStrenght * WindStrenghtFloat );
			float cos1075 = cos( ( ( tex2D( NoiseTextureFloat, worldNoise1038.rg ) * i.vertexColor.a ) * 0.5 * _WiggleStrenght ).r );
			float sin1075 = sin( ( ( tex2D( NoiseTextureFloat, worldNoise1038.rg ) * i.vertexColor.a ) * 0.5 * _WiggleStrenght ).r );
			float2 rotator1075 = mul( i.uv_texcoord - float2( 0.5,0.5 ) , float2x2( cos1075 , -sin1075 , sin1075 , cos1075 )) + float2( 0.5,0.5 );
			#ifdef _WIGGLE_ON
				float2 staticSwitch1033 = rotator1075;
			#else
				float2 staticSwitch1033 = i.uv_texcoord;
			#endif
			float4 tex2DNode97 = tex2D( _MainTex, staticSwitch1033 );
			float4 temp_output_43_0_g1 = _SpecularColor;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g2 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float3 normalizeResult64_g1 = normalize( (WorldNormalVector( i , float3(0,0,1) )) );
			float dotResult19_g1 = dot( normalizeResult4_g2 , normalizeResult64_g1 );
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 temp_output_40_0_g1 = ( ase_lightColor * ase_lightAtten );
			float dotResult14_g1 = dot( normalizeResult64_g1 , ase_worldlightDir );
			UnityGI gi34_g1 = gi;
			float3 diffNorm34_g1 = normalizeResult64_g1;
			gi34_g1 = UnityGI_Base( data, 1, diffNorm34_g1 );
			float3 indirectDiffuse34_g1 = gi34_g1.indirect.diffuse + diffNorm34_g1 * 0.0001;
			float clampResult1179 = clamp( i.vertexColor.g , 0.0 , 1.0 );
			float4 lerpResult1189 = lerp( ( ( _GrassBottomColour * _GrassBottomStrength ) * _GrassColour ) , _GrassColour , ( clampResult1179 * _DarkerLength ));
			float4 lerpResult1182 = lerp( _GrassColour , ( ( _GrassTipColour * _GrassTipStrength ) * _GrassColour ) , clampResult1179);
			float4 TipAndRootColoring1200 = ( lerpResult1189 + lerpResult1182 );
			float4 temp_output_42_0_g1 = saturate( ( TipAndRootColoring1200 * tex2DNode97.a ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir1148 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult1149 = normalize( objToWorldDir1148 );
			float3 ObjectToWrld1150 = normalizeResult1149;
			float dotResult1158 = dot( -( ase_worldlightDir + ( ObjectToWrld1150 * _NormalFactor ) ) , ase_worldViewDir );
			float dotResult1163 = dot( pow( dotResult1158 , _TranslucencyPower ) , _TranslucencyScale );
			float4 Translucency1170 = saturate( ( saturate( ( dotResult1163 * ( (_MinNew + (ase_lightAtten - _MinOld) * (_MaxNew - _MinNew) / (_Maxold - _MinOld)) * _LightAtten ) ) ) * _Translucencycolor ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			UnityGI gi1264 = gi;
			float3 diffNorm1264 = ase_worldNormal;
			gi1264 = UnityGI_Base( data, 1, diffNorm1264 );
			float3 indirectDiffuse1264 = gi1264.indirect.diffuse + diffNorm1264 * 0.0001;
			float RootAmbient1248 = saturate( ( i.vertexColor.r + _RootAmbient ) );
			float simplePerlin2D1239 = snoise( (( ase_worldPos * ase_vertex3Pos )).xz*_ValueRandom.x );
			simplePerlin2D1239 = simplePerlin2D1239*0.5 + 0.5;
			float clampResult1254 = clamp( simplePerlin2D1239 , _DarkeningClamp , _LighteningClamp );
			float RandomDarkening1227 = ( clampResult1254 + _RootDarkeningFactor );
			c.rgb = ( ( ( ( float4( (temp_output_43_0_g1).rgb , 0.0 ) * (temp_output_43_0_g1).a * pow( max( dotResult19_g1 , 0.0 ) , ( _Shininess * 128.0 ) ) * temp_output_40_0_g1 ) + ( ( ( temp_output_40_0_g1 * max( dotResult14_g1 , 0.0 ) ) + float4( indirectDiffuse34_g1 , 0.0 ) ) * float4( (temp_output_42_0_g1).rgb , 0.0 ) ) ) + Translucency1170 + ( _Ambient * float4( indirectDiffuse1264 , 0.0 ) ) ) * ( RootAmbient1248 * RandomDarkening1227 ) ).rgb;
			c.a = 1;
			clip( tex2DNode97.a - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
			o.Emission = _Color0.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers vulkan xbox360 psp2 n3ds wiiu 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows nolightmap  nodirlightmap dithercrossfade vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=17800
314;73;1172;506;-3114.453;-788.0195;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1052;1265.961,1465.902;Inherit;False;1606.407;663.0706;World Noise;15;1065;1064;1063;1062;1061;1059;1060;1057;1058;1054;1078;1055;1056;1053;1077;World Noise;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.Vector3Node;867;961.4112,1361.905;Float;False;Global;WindDirection;WindDirection;14;0;Create;True;0;0;False;0;0,0,0;0,0,-1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1053;1295.597,1741.238;Inherit;False;FLOAT2;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1145;1232.87,-1078.355;Inherit;False;669.4249;238.4037;Comment;3;1149;1148;1147;Object To World;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;1056;1503.598,1741.238;Inherit;False;World;World;True;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;1055;1295.207,1525.581;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1078;1581.201,2015.507;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1054;1460.903,1916.038;Float;False;Constant;WindSpeedFloat;WindSpeedFloat;5;0;Create;False;0;0;False;0;0.4;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1147;1268.322,-1034.654;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;1057;1579.412,1521.734;Inherit;False;FLOAT2;0;2;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1058;1768.826,1899.9;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;1060;1931.242,1532.904;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1059;1839.375,1677.775;Float;False;Constant;WindTurbulenceFloat;WindTurbulenceFloat;6;0;Create;False;0;0;False;0;0.1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1148;1498.296,-1041.355;Inherit;True;Object;World;False;Fast;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1061;2147.692,1529.906;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;1149;1753.294,-1032.355;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1146;590.4232,-636.2502;Inherit;False;2600.477;851.0789;Comment;25;1169;1168;1167;1166;1165;1164;1163;1162;1161;1160;1159;1158;1157;1156;1155;1154;1153;1152;1151;1174;1269;1270;1272;1271;1273;Translucency and SSS;1,0.7920545,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1150;2029.949,-1029.211;Inherit;False;ObjectToWrld;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;1077;2302.947,1528.563;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;10,10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1064;2357.26,1902.282;Float;False;Property;WindStrenghtFloat;WindStrenghtFloat;9;0;Create;False;0;0;False;0;0.8;0.576;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1152;638.3962,-281.5053;Inherit;False;1150;ObjectToWrld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1062;2443.763,1531.144;Inherit;True;Property;NoiseTextureFloat;NoiseTexture;7;1;[NoScaleOffset];Create;False;0;0;False;0;-1;None;e5055e0d246bd1047bdb28057a93753c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1151;675.5552,-139.258;Inherit;False;Property;_NormalFactor;NormalFactor ;0;0;Create;True;0;0;False;0;0;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1063;2360.906,1796.001;Float;False;Property;_WindStrenght;Wind Strenght;8;0;Create;False;0;0;False;0;0.5;1.369;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1153;640.4232,-485.6684;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1065;2734.054,1777.316;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1154;990.0325,-200.8258;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1199;4173.097,-295.4532;Inherit;False;1176.547;916.6212;Comment;19;1187;1181;1182;292;1179;1193;1192;1189;1195;1178;1188;1180;1194;1190;1200;1207;1208;1209;1210;Tip and Root Coloring;0.5752331,1,0,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1155;983.8185,-475.8617;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1038;2936.422,1769.995;Float;False;worldNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1188;4235.272,-111.7499;Inherit;False;Property;_GrassTipStrength;GrassTipStrength;23;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1180;4498.654,-245.4532;Inherit;False;Property;_GrassTipColour;GrassTipColour;22;0;Create;True;0;0;False;0;1,1,1,0;0.385597,0.737255,0.2549018,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;1157;1217.609,-518.2265;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1156;1215.324,-409.4002;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;1040;1894.985,756.4117;Inherit;False;1038;worldNoise;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1190;4891.875,-241.7645;Inherit;False;Property;_GrassBottomColour;GrassBottomColour;21;0;Create;True;0;0;False;0;1,1,1,0;0.3843136,0.737255,0.2549019,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1178;4201.625,222.1549;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1066;2147.645,641.9539;Inherit;False;1007.189;586.5881;UV Animation;8;1075;1074;1073;1072;1071;1070;1068;1076;UV Animation;0.7678117,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1194;4856.035,-26.8321;Inherit;False;Property;_GrassBottomStrength;GrassBottomStrength;24;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1273;1594.093,142.8564;Inherit;False;Property;_MaxNew;Max New;39;0;Create;True;0;0;False;0;0;0.76;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1192;5135.506,-19.46992;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1159;1433.696,-287.1689;Inherit;False;Property;_TranslucencyPower;Translucency Power;12;0;Create;True;0;0;False;0;0;0.98;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1179;4563.472,317.6736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;292;4227.083,19.85192;Float;False;Property;_GrassColour;GrassColour;5;0;Create;True;0;0;False;0;1,1,1,1;0.1474916,0.2547169,0.102127,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1210;4711.955,466.7957;Inherit;False;Property;_DarkerLength;DarkerLength;36;0;Create;True;0;0;False;0;0;1.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1258;1745.53,3133.187;Inherit;False;1832.672;512.259;Comment;12;1216;1253;1239;1237;1214;1240;1255;1256;1254;1242;1227;1262;RandomDarkening;0.2520173,0.3867925,0.2463065,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;1076;2393.056,883.4951;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1187;4693.157,-8.837678;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1271;1594.067,62.97063;Inherit;False;Property;_MinNew;Min New;38;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1272;1597.057,-29.37733;Inherit;False;Property;_Maxold;Max old;35;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1270;1592.954,-117.7639;Inherit;False;Property;_MinOld;Min Old;37;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1068;2256.481,689.1251;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;1062;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;1174;1388.556,-195.7862;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1158;1457.493,-521.8968;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1160;1714.259,-270.52;Inherit;False;Property;_TranslucencyScale;Translucency Scale;16;0;Create;True;0;0;False;0;0;0.42;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1193;5187.644,131.0045;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1262;1747.345,3217.459;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1181;4755.949,133.7609;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1070;2603.455,916.0801;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;1161;1701.745,-503.6602;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1209;4971.19,345.114;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1072;2296.218,1045.342;Float;False;Constant;GrassWiggleFloat;GrassWiggleFloat;7;0;Create;False;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1162;1964.938,30.77526;Inherit;False;Property;_LightAtten;Light Atten ;20;0;Create;True;0;0;False;0;0;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1071;2297.54,1134.77;Float;False;Property;_WiggleStrenght;Wiggle Strenght;13;0;Create;False;0;0;False;0;0.5;0.245;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1269;1770.7,-179.5983;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1.27;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;1240;1806.161,3434.26;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1073;2749.524,916.9191;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1074;2640.914,746.6478;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;1189;5146.442,305.4308;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1237;2002.694,3263.127;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;1182;4726.355,296.5927;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;1163;1945.134,-439.4781;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1164;2152.508,-127.5361;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1195;4946.693,486.168;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;1214;2269.648,3334.401;Inherit;False;Property;_ValueRandom;ValueRandom;28;0;Create;True;0;0;False;0;1,2;0.00075,0.55;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;746;3306.542,776.9384;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1257;1924.187,3932.415;Inherit;False;939.1582;399.916;Comment;5;1246;1244;1247;1248;1249;BladeRootAmbient;1,0.6136042,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1165;2276.703,-343.0824;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;1216;2205.006,3183.187;Inherit;False;True;False;True;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;1075;2892.845,797.6151;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;1166;2594.022,-341.7472;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1033;3577.498,858.7823;Float;False;Property;_Wiggle;Wiggle;10;0;Create;True;0;0;False;0;1;1;0;True;_WIND_ON;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1255;2693.664,3329.447;Inherit;False;Property;_DarkeningClamp;DarkeningClamp;31;0;Create;True;0;0;False;0;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1239;2460.534,3242.624;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1041;2261.57,2212.71;Inherit;False;604.5423;478.4144;Vertex Animation;3;1039;854;853;Vertex Animation;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.VertexColorNode;1244;1974.187,3982.415;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1256;2697.75,3409.382;Inherit;False;Property;_LighteningClamp;LighteningClamp;32;0;Create;True;0;0;False;0;0;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1246;2076.345,4216.331;Inherit;False;Property;_RootAmbient;RootAmbient;30;0;Create;True;0;0;False;0;0;2.99;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1167;2745.328,-134.4277;Inherit;False;Property;_Translucencycolor;Translucency color;14;0;Create;True;0;0;False;0;0,0,0,0;0.6916843,0.9056604,0.3460305,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1200;5141.184,476.2362;Inherit;False;TipAndRootColoring;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1249;2275.786,4084.771;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;853;2316.312,2301.206;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1168;2911.383,-353.5175;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1242;2861.75,3529.446;Inherit;False;Property;_RootDarkeningFactor;RootDarkeningFactor;29;0;Create;True;0;0;False;0;0;0.52;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;1254;2890.795,3249.097;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1201;3781.151,828.78;Inherit;False;1200;TipAndRootColoring;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;97;3656.205,1073.861;Inherit;True;Property;_MainTex;MainTex;6;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;24ecc2fb95c0ea348818fda202b81f83;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1039;2307.059,2531.358;Inherit;False;1038;worldNoise;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1253;3162.372,3425.997;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;293;4003.225,915.0611;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;854;2607.012,2520.626;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1247;2465.345,4127.331;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1169;3073.452,-275.1888;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1248;2639.345,4173.331;Inherit;False;RootAmbient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1227;3335.202,3421.233;Inherit;False;RandomDarkening;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1263;4178.174,1068.314;Inherit;False;Property;_Ambient;Ambient;40;0;Create;True;0;0;False;0;0,0,0,0;0.1385097,0.2075471,0.09104653,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;872;3171.533,1371.818;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1051;4272.08,937.7651;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;1264;4249.425,1252.262;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1170;3327.119,-163.8007;Inherit;False;Translucency;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1229;4525.482,1404.263;Inherit;False;1227;RandomDarkening;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1250;4625.568,1493.669;Inherit;False;1248;RootAmbient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1265;4544.991,1199.407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;1260;3545.531,1915.927;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;1029;3342.364,1373.903;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;1261;4422.143,1034.459;Inherit;False;Blinn-Phong Light;1;;1;cf814dba44d007a4e958d2ddd5813da6;0;3;42;COLOR;0,0,0,0;False;52;FLOAT3;0,0,0;False;43;COLOR;0,0,0,0;False;2;COLOR;0;FLOAT;57
Node;AmplifyShaderEditor.GetLocalVarNode;1171;4492.374,1327.421;Inherit;False;1170;Translucency;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;1031;3576.195,1345.762;Float;False;Property;_Wind;Wind;11;0;Create;True;0;0;False;0;1;1;1;True;_WIND_ON;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1172;4746.476,1150.769;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1251;4785.568,1462.669;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TouchReactNode;1259;3918.837,2132.771;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1206;4689.924,1477.979;Inherit;False;Property;_Color0;Color 0;27;0;Create;True;0;0;False;0;0,0,0,0;0.01067996,0.04716971,0.001557494,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;1136;3501.626,2137.387;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;1207;4183.372,414.9834;Inherit;True;Property;_TextureSample1;Texture Sample 1;34;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1208;4410.365,311.7106;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1138;3118.771,2285.909;Inherit;False;Property;_Downfall;Downfall;17;0;Create;True;0;0;False;0;3.29;0.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1142;3245.309,2396.813;Inherit;False;Property;_Zfall;Zfall;19;0;Create;True;0;0;False;0;3.29;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;1202;4384.251,1498.44;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1140;3369.94,2049.235;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1139;3124.118,1956.798;Inherit;False;Property;_XFall;XFall;18;0;Create;True;0;0;False;0;3.29;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1203;4104.924,1503.765;Inherit;False;Property;_DepthFadeLength;DepthFadeLength;25;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1090;4649.448,1799.526;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1141;3445.939,2277.679;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1094;3045.77,2101.601;Inherit;False;Property;_Position;Position;15;0;Create;True;0;0;False;0;0.39,0.18,-0.03;-0.5,7.49,26;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1204;3976.989,1643.74;Inherit;False;Property;_DepthFadeOffset;DepthFadeOffset;26;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1228;4902.042,1296.554;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1137;3378.846,2154.981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;5118.991,1085.934;Float;False;True;-1;2;;0;0;CustomLighting;IL3DN/Grass;False;False;False;False;False;False;True;False;True;False;False;False;True;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.53;True;True;0;False;TransparentCutout;;AlphaTest;All;9;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;33;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1053;0;867;0
WireConnection;1056;0;1053;0
WireConnection;1057;0;1055;0
WireConnection;1058;0;1056;0
WireConnection;1058;1;1054;0
WireConnection;1058;2;1078;0
WireConnection;1060;0;1057;0
WireConnection;1060;2;1058;0
WireConnection;1148;0;1147;0
WireConnection;1061;0;1060;0
WireConnection;1061;1;1059;0
WireConnection;1149;0;1148;0
WireConnection;1150;0;1149;0
WireConnection;1077;0;1061;0
WireConnection;1062;1;1077;0
WireConnection;1065;0;1062;0
WireConnection;1065;1;1063;0
WireConnection;1065;2;1064;0
WireConnection;1154;0;1152;0
WireConnection;1154;1;1151;0
WireConnection;1155;0;1153;0
WireConnection;1155;1;1154;0
WireConnection;1038;0;1065;0
WireConnection;1157;0;1155;0
WireConnection;1192;0;1190;0
WireConnection;1192;1;1194;0
WireConnection;1179;0;1178;2
WireConnection;1187;0;1180;0
WireConnection;1187;1;1188;0
WireConnection;1068;1;1040;0
WireConnection;1158;0;1157;0
WireConnection;1158;1;1156;0
WireConnection;1193;0;1192;0
WireConnection;1193;1;292;0
WireConnection;1181;0;1187;0
WireConnection;1181;1;292;0
WireConnection;1070;0;1068;0
WireConnection;1070;1;1076;4
WireConnection;1161;0;1158;0
WireConnection;1161;1;1159;0
WireConnection;1209;0;1179;0
WireConnection;1209;1;1210;0
WireConnection;1269;0;1174;0
WireConnection;1269;1;1270;0
WireConnection;1269;2;1272;0
WireConnection;1269;3;1271;0
WireConnection;1269;4;1273;0
WireConnection;1073;0;1070;0
WireConnection;1073;1;1072;0
WireConnection;1073;2;1071;0
WireConnection;1189;0;1193;0
WireConnection;1189;1;292;0
WireConnection;1189;2;1209;0
WireConnection;1237;0;1262;0
WireConnection;1237;1;1240;0
WireConnection;1182;0;292;0
WireConnection;1182;1;1181;0
WireConnection;1182;2;1179;0
WireConnection;1163;0;1161;0
WireConnection;1163;1;1160;0
WireConnection;1164;0;1269;0
WireConnection;1164;1;1162;0
WireConnection;1195;0;1189;0
WireConnection;1195;1;1182;0
WireConnection;1165;0;1163;0
WireConnection;1165;1;1164;0
WireConnection;1216;0;1237;0
WireConnection;1075;0;1074;0
WireConnection;1075;2;1073;0
WireConnection;1166;0;1165;0
WireConnection;1033;1;746;0
WireConnection;1033;0;1075;0
WireConnection;1239;0;1216;0
WireConnection;1239;1;1214;0
WireConnection;1200;0;1195;0
WireConnection;1249;0;1244;1
WireConnection;1249;1;1246;0
WireConnection;1168;0;1166;0
WireConnection;1168;1;1167;0
WireConnection;1254;0;1239;0
WireConnection;1254;1;1255;0
WireConnection;1254;2;1256;0
WireConnection;97;1;1033;0
WireConnection;1253;0;1254;0
WireConnection;1253;1;1242;0
WireConnection;293;0;1201;0
WireConnection;293;1;97;4
WireConnection;854;0;853;4
WireConnection;854;1;1039;0
WireConnection;1247;0;1249;0
WireConnection;1169;0;1168;0
WireConnection;1248;0;1247;0
WireConnection;1227;0;1253;0
WireConnection;872;0;867;0
WireConnection;872;1;854;0
WireConnection;1051;0;293;0
WireConnection;1170;0;1169;0
WireConnection;1265;0;1263;0
WireConnection;1265;1;1264;0
WireConnection;1029;0;872;0
WireConnection;1261;42;1051;0
WireConnection;1031;0;1029;0
WireConnection;1172;0;1261;0
WireConnection;1172;1;1171;0
WireConnection;1172;2;1265;0
WireConnection;1251;0;1250;0
WireConnection;1251;1;1229;0
WireConnection;1259;0;1260;0
WireConnection;1136;0;1140;0
WireConnection;1136;1;1137;0
WireConnection;1136;2;1141;0
WireConnection;1208;0;1178;2
WireConnection;1208;1;1207;0
WireConnection;1202;0;1203;0
WireConnection;1202;1;1204;0
WireConnection;1140;0;1094;1
WireConnection;1140;1;1139;0
WireConnection;1090;0;1031;0
WireConnection;1090;1;1259;0
WireConnection;1141;0;1142;0
WireConnection;1141;1;1094;3
WireConnection;1228;0;1172;0
WireConnection;1228;1;1251;0
WireConnection;1137;0;1094;2
WireConnection;1137;1;1138;0
WireConnection;0;2;1206;0
WireConnection;0;10;97;4
WireConnection;0;13;1228;0
WireConnection;0;11;1090;0
ASEEND*/
//CHKSM=7460134984511AA0D718EC8BB57B019ABB7786D5
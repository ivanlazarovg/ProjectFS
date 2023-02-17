// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "IL3DN/Pine2"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.3
		_NormalFactor("NormalFactor ", Float) = 1.6
		_DistortNormal("DistortNormal", Float) = 0
		_Color("Color", Color) = (1,0,0,1)
		_MainTex("MainTex", 2D) = "white" {}
		[NoScaleOffset]NoiseTextureFloat1("NoiseTexture", 2D) = "white" {}
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		WindSpeedFloat1("WindSpeedFloat", Range( 0 , 1)) = 0.4
		[Toggle(_WIND_ON)] _Wind("Wind", Float) = 1
		WindTurbulenceFloat1("WindTurbulenceFloat", Range( 0 , 1)) = 0.1
		_WindDirection("WindDirection", Vector) = (0,0,0,0)
		_SpecularPower("Specular Power", Float) = 0
		_TranslucencyPower("Translucency Power", Float) = 1.52
		_Translucencycolor("Translucency color", Color) = (0,0,0,0)
		_Color0("Color 0", Color) = (0,0,0,0)
		_WindStrenght1("Wind Strenght", Range( 0 , 1)) = 0.5
		_SpecularScale("Specular Scale", Float) = 0
		_Vector2("Vector 2", Vector) = (0,0,0,0)
		_TranslucencyScale("Translucency Scale", Float) = 11.58
		[Toggle(_WIGGLE_ON)] _Wiggle("Wiggle", Float) = 1
		_WiggleStrenght("Wiggle Strenght", Range( 0 , 1)) = 1
		_Norms("Norms", Vector) = (0,0,0,0)
		_LightAttenSpecular("Light Atten Specular", Float) = 0
		_LightAtten("Light Atten ", Float) = -0.88
		_RandomnessColor("Randomness Color", Color) = (0.8349056,0.8351322,1,0)
		_Ambient("Ambient", Color) = (0,0,0,0)
		[HDR]_AmbientEmissive("AmbientEmissive", Color) = (0,0,0,0)
		_DissolveNoiseStrength("DissolveNoiseStrength", Float) = 1.72
		_dissolvecutoffpoint("dissolvecutoffpoint", Float) = -0.56
		[Toggle(_KEYWORD0_ON)] _Keyword0("Keyword 0", Float) = 0
		_EdgeWidth("EdgeWidth", Float) = 0.04
		[HDR]_EdgeDissolveColor("EdgeDissolveColor", Color) = (3.184314,0,0,0)
		_DissolveScale("DissolveScale", Float) = 0
		[KeywordEnum(X,Y,Z)] _Axis("Axis", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TreeTransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile __ _WIND_ON
		#pragma shader_feature_local _KEYWORD0_ON
		#pragma shader_feature_local _AXIS_X _AXIS_Y _AXIS_Z
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

		uniform float3 _WindDirection;
		uniform sampler2D NoiseTextureFloat1;
		uniform float WindSpeedFloat1;
		uniform float WindTurbulenceFloat1;
		uniform float _WindStrenght1;
		uniform float3 _Norms;
		uniform float4 _AmbientEmissive;
		uniform float _DissolveScale;
		uniform float _DissolveNoiseStrength;
		uniform float _dissolvecutoffpoint;
		uniform float _EdgeWidth;
		uniform float4 _EdgeDissolveColor;
		uniform sampler2D _MainTex;
		uniform sampler2D _TextureSample0;
		uniform float _WiggleStrenght;
		uniform float4 _Color;
		uniform float4 _RandomnessColor;
		uniform float3 _Vector2;
		uniform float _NormalFactor;
		uniform float _TranslucencyPower;
		uniform float _TranslucencyScale;
		uniform float _LightAtten;
		uniform float4 _Translucencycolor;
		uniform float _DistortNormal;
		uniform float _SpecularPower;
		uniform float _SpecularScale;
		uniform float _LightAttenSpecular;
		uniform float4 _Color0;
		uniform float4 _Ambient;
		uniform float _Cutoff = 0.3;


		float2 UnityGradientNoiseDir( float2 p )
		{
			p = fmod(p , 289);
			float x = fmod((34 * p.x + 1) * p.x , 289) + p.y;
			x = fmod( (34 * x + 1) * x , 289);
			x = frac( x / 41 ) * 2 - 1;
			return normalize( float2(x - floor(x + 0.5 ), abs( x ) - 0.5 ) );
		}
		
		float UnityGradientNoise( float2 UV, float Scale )
		{
			float2 p = UV * Scale;
			float2 ip = floor( p );
			float2 fp = frac( p );
			float d00 = dot( UnityGradientNoiseDir( ip ), fp );
			float d01 = dot( UnityGradientNoiseDir( ip + float2( 0, 1 ) ), fp - float2( 0, 1 ) );
			float d10 = dot( UnityGradientNoiseDir( ip + float2( 1, 0 ) ), fp - float2( 1, 0 ) );
			float d11 = dot( UnityGradientNoiseDir( ip + float2( 1, 1 ) ), fp - float2( 1, 1 ) );
			fp = fp * fp * fp * ( fp * ( fp * 6 - 15 ) + 10 );
			return lerp( lerp( d00, d01, fp.y ), lerp( d10, d11, fp.y ), fp.x ) + 0.5;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 temp_output_1041_0 = float3( (_WindDirection).xz ,  0.0 );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 panner1046 = ( 1.0 * _Time.y * ( temp_output_1041_0 * WindSpeedFloat1 * 10.0 ).xy + (ase_worldPos).xy);
			float4 worldNoise1056 = ( tex2Dlod( NoiseTextureFloat1, float4( ( ( panner1046 * WindTurbulenceFloat1 ) / float2( 10,10 ) ), 0, 0.0) ) * _WindStrenght1 * 0.8 );
			float4 transform1149 = mul(unity_WorldToObject,( float4( _WindDirection , 0.0 ) * ( ( v.color.a * worldNoise1056 ) + ( worldNoise1056 * v.color.g ) ) ));
			#ifdef _WIND_ON
				float4 staticSwitch1161 = transform1149;
			#else
				float4 staticSwitch1161 = float4( 0,0,0,0 );
			#endif
			v.vertex.xyz += staticSwitch1161.xyz;
			v.vertex.w = 1;
			float3 normalizeResult1152 = normalize( ( _Norms * _WorldSpaceLightPos0.xyz ) );
			v.normal = normalizeResult1152;
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
			float3 temp_output_1041_0 = float3( (_WindDirection).xz ,  0.0 );
			float3 ase_worldPos = i.worldPos;
			float2 panner1046 = ( 1.0 * _Time.y * ( temp_output_1041_0 * WindSpeedFloat1 * 10.0 ).xy + (ase_worldPos).xy);
			float4 worldNoise1056 = ( tex2D( NoiseTextureFloat1, ( ( panner1046 * WindTurbulenceFloat1 ) / float2( 10,10 ) ) ) * _WindStrenght1 * 0.8 );
			float cos1079 = cos( ( ( tex2D( _TextureSample0, worldNoise1056.rg ) * i.vertexColor.g ) * 1.0 * _WiggleStrenght ).r );
			float sin1079 = sin( ( ( tex2D( _TextureSample0, worldNoise1056.rg ) * i.vertexColor.g ) * 1.0 * _WiggleStrenght ).r );
			float2 rotator1079 = mul( i.uv_texcoord - float2( 0.25,0.25 ) , float2x2( cos1079 , -sin1079 , sin1079 , cos1079 )) + float2( 0.25,0.25 );
			#ifdef _WIGGLE_ON
				float2 staticSwitch1083 = rotator1079;
			#else
				float2 staticSwitch1083 = i.uv_texcoord;
			#endif
			float2 UVswitch1088 = staticSwitch1083;
			float4 tex2DNode1106 = tex2D( _MainTex, UVswitch1088 );
			float3 break1210 = ase_worldPos;
			#if defined(_AXIS_X)
				float staticSwitch1227 = break1210.x;
			#elif defined(_AXIS_Y)
				float staticSwitch1227 = break1210.y;
			#elif defined(_AXIS_Z)
				float staticSwitch1227 = break1210.z;
			#else
				float staticSwitch1227 = break1210.x;
			#endif
			float gradientNoise1195 = UnityGradientNoise(i.uv_texcoord,_DissolveScale);
			gradientNoise1195 = gradientNoise1195*0.5 + 0.5;
			float temp_output_1207_0 = ( (-_DissolveNoiseStrength + (gradientNoise1195 - 0.0) * (_DissolveNoiseStrength - -_DissolveNoiseStrength) / (1.0 - 0.0)) + _dissolvecutoffpoint );
			float Dissolve1212 = step( staticSwitch1227 , temp_output_1207_0 );
			#ifdef _KEYWORD0_ON
				float staticSwitch1214 = ( tex2DNode1106.a * Dissolve1212 );
			#else
				float staticSwitch1214 = tex2DNode1106.a;
			#endif
			SurfaceOutputStandardSpecular s1194 = (SurfaceOutputStandardSpecular ) 0;
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float4 ase_vertexTangent = mul( unity_WorldToObject, float4( ase_worldTangent, 0 ) );
			float dotResult1104 = dot( float3( (_Vector2).xz ,  0.0 ) , ase_vertexTangent.xyz );
			float4 lerpResult1126 = lerp( ( _Color * tex2DNode1106.a ) , _RandomnessColor , abs( dotResult1104 ));
			s1194.Albedo = saturate( lerpResult1126 ).rgb;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			s1194.Normal = ase_worldNormal;
			s1194.Emission = float3( 0,0,0 );
			s1194.Specular = float3( 0,0,0 );
			s1194.Smoothness = 0.0;
			s1194.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi1194 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1194 = UnityGlossyEnvironmentSetup( s1194.Smoothness, data.worldViewDir, s1194.Normal, float3(0,0,0));
			gi1194 = UnityGlobalIllumination( data, s1194.Occlusion, s1194.Normal, g1194 );
			#endif

			float3 surfResult1194 = LightingStandardSpecular ( s1194, viewDir, gi1194 ).rgb;
			surfResult1194 += s1194.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1194
			surfResult1194 -= s1194.Emission;
			#endif//1194
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir1055 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float3 normalizeResult1057 = normalize( objToWorldDir1055 );
			float3 ObjectToWrld1061 = normalizeResult1057;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult1086 = dot( -( ase_worldlightDir + ( ObjectToWrld1061 * _NormalFactor ) ) , ase_worldViewDir );
			float dotResult1100 = dot( pow( dotResult1086 , _TranslucencyPower ) , _TranslucencyScale );
			float4 Translucency1138 = saturate( ( saturate( ( dotResult1100 * ( ase_lightAtten * _LightAtten ) ) ) * _Translucencycolor ) );
			float dotResult1084 = dot( ( ase_worldlightDir + ( ObjectToWrld1061 * _DistortNormal ) ) , ase_worldlightDir );
			float dotResult1102 = dot( pow( dotResult1084 , _SpecularPower ) , _SpecularScale );
			float4 Specular1137 = saturate( ( saturate( ( dotResult1102 * ( ase_lightAtten * _LightAttenSpecular ) ) ) * _Color0 ) );
			UnityGI gi1190 = gi;
			float3 diffNorm1190 = ase_worldNormal;
			gi1190 = UnityGI_Base( data, 1, diffNorm1190 );
			float3 indirectDiffuse1190 = gi1190.indirect.diffuse + diffNorm1190 * 0.0001;
			c.rgb = ( float4( surfResult1194 , 0.0 ) + Translucency1138 + Specular1137 + ( _Ambient * float4( indirectDiffuse1190 , 0.0 ) ) ).rgb;
			c.a = 1;
			clip( staticSwitch1214 - _Cutoff );
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
			float gradientNoise1195 = UnityGradientNoise(i.uv_texcoord,_DissolveScale);
			gradientNoise1195 = gradientNoise1195*0.5 + 0.5;
			float temp_output_1207_0 = ( (-_DissolveNoiseStrength + (gradientNoise1195 - 0.0) * (_DissolveNoiseStrength - -_DissolveNoiseStrength) / (1.0 - 0.0)) + _dissolvecutoffpoint );
			float3 ase_worldPos = i.worldPos;
			float3 break1210 = ase_worldPos;
			#if defined(_AXIS_X)
				float staticSwitch1227 = break1210.x;
			#elif defined(_AXIS_Y)
				float staticSwitch1227 = break1210.y;
			#elif defined(_AXIS_Z)
				float staticSwitch1227 = break1210.z;
			#else
				float staticSwitch1227 = break1210.x;
			#endif
			float4 DissolveEmission1223 = ( step( temp_output_1207_0 , ( staticSwitch1227 + _EdgeWidth ) ) * _EdgeDissolveColor );
			#ifdef _KEYWORD0_ON
				float4 staticSwitch1222 = ( DissolveEmission1223 + _AmbientEmissive );
			#else
				float4 staticSwitch1222 = _AmbientEmissive;
			#endif
			o.Emission = staticSwitch1222.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma exclude_renderers vulkan xbox360 xboxseries playstation psp2 n3ds wiiu switch nomrt 
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows dithercrossfade vertex:vertexDataFunc 

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
Version=18912
314;73;1244;655;740.9836;823.7296;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;1036;-812.1006,888.0051;Inherit;False;1611.173;648.4346;World Noise;15;1054;1052;1051;1050;1048;1047;1046;1045;1044;1043;1042;1041;1040;1039;1038;World Noise;1,0,0.02020931,1;0;0
Node;AmplifyShaderEditor.Vector3Node;1037;-1185.59,791.9252;Float;False;Property;_WindDirection;WindDirection;9;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1038;-782.4636,1163.341;Inherit;False;FLOAT2;0;2;1;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1042;-777.1946,948.6292;Float;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1039;-617.1587,1339.292;Float;False;Property;WindSpeedFloat1;WindSpeedFloat;6;0;Create;False;0;0;0;False;0;False;0.4;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1040;-487.5566,1436.809;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1041;-574.4636,1163.341;Inherit;False;World;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;1044;-430.7236,944.6661;Inherit;False;FLOAT2;0;1;2;2;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1043;-308.6406,1304.614;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;1046;-141.6177,950.9631;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1045;-238.9557,1113.197;Float;False;Property;WindTurbulenceFloat1;WindTurbulenceFloat;8;0;Create;False;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1047;60.38037,952.6401;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;1049;-2204.737,-2193.566;Inherit;False;669.4249;238.4037;Comment;3;1057;1055;1053;Object To World;1,1,1,1;0;0
Node;AmplifyShaderEditor.PosVertexDataNode;1053;-2130.438,-2102.667;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;1048;218.7014,949.0442;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;10,10;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1052;358.0774,948.4962;Inherit;True;Property;NoiseTextureFloat1;NoiseTexture;5;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;e5055e0d246bd1047bdb28057a93753c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1051;279.1995,1324.384;Float;False;Constant;WindStrenghtFloat1;WindStrenghtFloat;3;0;Create;False;0;0;0;False;0;False;0.8;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;1055;-1938.312,-2155.566;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;1050;282.8455,1218.104;Float;False;Property;_WindStrenght1;Wind Strenght;14;0;Create;False;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1054;655.9944,1199.419;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalizeNode;1057;-1655.013,-2141.066;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1056;844.2554,1193.881;Float;False;worldNoise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1060;-762.2417,-2252.88;Inherit;False;2600.477;851.0789;Comment;20;1134;1120;1116;1113;1107;1101;1100;1095;1094;1090;1087;1086;1082;1081;1075;1072;1067;1063;1062;1187;Translucency and SSS;1,0.7920545,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1061;-1250.418,-2167.698;Inherit;False;ObjectToWrld;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1059;-1049.49,224.2388;Inherit;False;1056;worldNoise;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;1058;-794.6216,114.1392;Inherit;False;1014.989;570.0199;UV Animation;8;1079;1074;1073;1071;1069;1068;1065;1064;UV Animation;0.7678117,1,0,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;1062;-677.1106,-1755.888;Inherit;False;Property;_NormalFactor;NormalFactor ;1;0;Create;True;0;0;0;False;0;False;1.6;0.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1063;-714.2687,-1898.135;Inherit;False;1061;ObjectToWrld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;1065;-489.2556,362.9518;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1066;1320.687,-812.3179;Inherit;False;1061;ObjectToWrld;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1072;-712.2427,-2102.298;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;1064;-622.2487,168.9305;Inherit;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;0;False;0;False;-1;None;e5055e0d246bd1047bdb28057a93753c;True;0;False;white;Auto;False;Instance;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1070;1357.845,-670.0709;Inherit;False;Property;_DistortNormal;DistortNormal;2;0;Create;True;0;0;0;False;0;False;0;47.55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1067;-362.6337,-1817.456;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1075;-368.8477,-2092.491;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1071;-311.7787,356.1259;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;1069;-582.8336,526.3362;Float;False;Constant;_LeavesWiggleFloat;LeavesWiggleFloat;5;0;Create;True;0;0;0;False;0;False;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;1077;1469.096,-1030.422;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1076;1672.322,-731.6389;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;1068;-577.6146,604.6272;Float;False;Property;_WiggleStrenght;Wiggle Strenght;20;0;Create;True;0;0;0;False;0;False;1;0.412;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1073;-181.5137,463.5782;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NegateNode;1081;-135.0576,-2134.856;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1080;1895.082,-862.8224;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;1082;-137.3427,-2026.03;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;1074;-242.5697,190.6252;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1085;2115.988,-756.6179;Inherit;False;Property;_SpecularPower;Specular Power;10;0;Create;True;0;0;0;False;0;False;0;0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1087;81.03027,-1842.435;Inherit;False;Property;_TranslucencyPower;Translucency Power;11;0;Create;True;0;0;0;False;0;False;1.52;2.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1084;2137.364,-1042.529;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1086;100.1074,-2100.764;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1078;631.9343,593.7821;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1226;-1186.551,-788.1271;Inherit;False;Property;_DissolveScale;DissolveScale;36;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;1209;-571.3106,-479.4161;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RotatorNode;1079;-27.58569,317.2087;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0.25,0.25;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;1198;-996.3423,-496.4933;Inherit;False;Property;_DissolveNoiseStrength;DissolveNoiseStrength;31;0;Create;True;0;0;0;False;0;False;1.72;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1196;-1296.719,-963.3895;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;1095;402.5945,-1775.265;Inherit;False;Property;_TranslucencyScale;Translucency Scale;17;0;Create;True;0;0;0;False;0;False;11.58;7.92;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1090;334.9194,-2044.765;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1093;2733.227,-491.0388;Inherit;False;Property;_LightAttenSpecular;Light Atten Specular;25;0;Create;True;0;0;0;False;0;False;0;0.0001;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1188;2611.5,-594.6391;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;1187;547.4663,-1651.869;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1092;2437.551,-690.9558;Inherit;False;Property;_SpecularScale;Specular Scale;15;0;Create;True;0;0;0;False;0;False;0;53.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1083;976.7712,636.8582;Float;False;Property;_Wiggle;Wiggle;18;0;Create;True;0;0;0;False;0;False;1;1;1;True;_WIND_ON;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT2;0,0;False;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;1199;-889.3423,-598.4933;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;1210;-298.3451,-465.629;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;1094;698.2744,-1576.856;Inherit;False;Property;_LightAtten;Light Atten ;26;0;Create;True;0;0;0;False;0;False;-0.88;0.0077;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;1089;2369.875,-958.9479;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1195;-1002.199,-888.4352;Inherit;True;Gradient;True;True;2;0;FLOAT2;1,1;False;1;FLOAT;0.73;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1098;2834.797,-658.3499;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;1197;-690.6812,-812.8814;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1091;245.9033,157.2922;Inherit;False;Property;_Vector2;Vector 2;16;0;Create;True;0;0;0;False;0;False;0,0,0;36.79,2.37,-16.85;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;1102;2629.783,-901.8456;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1101;799.8445,-1744.167;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1088;1228.8,691.0022;Inherit;False;UVswitch;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;1227;-143.5359,-501.3983;Inherit;False;Property;_Axis;Axis;37;0;Create;True;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;3;X;Y;Z;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1100;594.8293,-1987.663;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1208;-457.6,-532.5165;Inherit;False;Property;_dissolvecutoffpoint;dissolvecutoffpoint;32;0;Create;True;0;0;0;False;0;False;-0.56;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1218;-276.0229,-904.3378;Inherit;False;Property;_EdgeWidth;EdgeWidth;34;0;Create;True;0;0;0;False;0;False;0.04;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1099;-144.2893,-332.748;Inherit;False;1088;UVswitch;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;1096;458.8313,159.7977;Inherit;False;True;False;True;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TangentVertexDataNode;1097;473.1365,382.9532;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;1217;-43.01498,-923.7803;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;1108;172.7334,1602.754;Inherit;False;619.4545;677.2183;Vertex Animation;5;1130;1123;1121;1119;1117;Vertex Animation;0,1,0.8708036,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1107;924.0393,-1959.713;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1103;2958.993,-873.8958;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1207;-352.3,-748.3165;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1114;-132.3446,1870.412;Inherit;False;1056;worldNoise;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1115;3276.311,-872.5598;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1118;3427.618,-664.241;Inherit;False;Property;_Color0;Color 0;13;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2244112,0.4431372,0.1411765,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;1104;701.3474,199.4297;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1106;197.4187,-367.7009;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1119;230.3804,2090.59;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;1113;1392.664,-1751.058;Inherit;False;Property;_Translucencycolor;Translucency color;12;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.5296329,0.7921569,0.1215686,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;1117;225.6833,1677.524;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;1219;304.0253,-908.4732;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1105;524.0914,-565.8282;Float;False;Property;_Color;Color;3;0;Create;True;0;0;0;False;0;False;1,0,0,1;0.1848258,0.3962264,0.1588643,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;1116;1241.358,-1958.377;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1221;317.6935,-698.9089;Inherit;False;Property;_EdgeDissolveColor;EdgeDissolveColor;35;1;[HDR];Create;True;0;0;0;False;0;False;3.184314,0,0,0;0.4434881,0.02719503,0.02719503,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1111;842.4214,-322.0269;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1220;623.5762,-813.3147;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;1110;979.9063,230.9078;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1122;3593.672,-884.3306;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1109;697.9478,-151.1481;Inherit;False;Property;_RandomnessColor;Randomness Color;28;0;Create;True;0;0;0;False;0;False;0.8349056,0.8351322,1,0;0.5294118,0.4250713,0.117647,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1121;499.1204,1974.326;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;1211;-32.11519,-697.377;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1123;497.3633,1836.765;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1120;1558.719,-1970.148;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1134;1766.372,-1887.261;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;1126;1056.68,-92.05505;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1212;212.7917,-504.7844;Inherit;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;1223;1031.627,-652.8827;Inherit;False;DissolveEmission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1130;647.5613,1897.965;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;1129;3801.326,-801.4437;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;1139;2139.192,912.2792;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.IndirectDiffuseLighting;1190;1988.382,562.8456;Inherit;False;World;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;1133;1545.056,102.7335;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1135;1204.498,789.0282;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1224;2366.658,57.70048;Inherit;False;1223;DissolveEmission;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1189;1917.131,378.8983;Inherit;False;Property;_Ambient;Ambient;29;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.07058164,0.2358491,0.02336241,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;1213;1068.747,501.494;Inherit;False;1212;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1140;2082.167,708.8651;Inherit;False;Property;_Norms;Norms;24;0;Create;True;0;0;0;False;0;False;0,0,0;6.28,1.39,-34.65;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;1137;4240.496,-646.6124;Inherit;False;Specular;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;1191;2373.09,201.0364;Inherit;False;Property;_AmbientEmissive;AmbientEmissive;30;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.07058164,0.2358491,0.02336241,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1138;2114.001,-1599.075;Inherit;False;Translucency;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CustomStandardSurface;1194;1875.679,124.156;Inherit;False;Specular;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;1142;1276.995,1143.613;Inherit;False;1528.586;547.6896;Adds adjustable snow to the pine leaves;14;1183;1181;1179;1178;1177;1171;1170;1166;1164;1163;1158;1157;1155;1153;SnowCoverage;0.6367924,0.8076684,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1143;2283.948,509.9911;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1145;2387.167,724.8651;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;1147;2254.647,432.3586;Inherit;False;1138;Translucency;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;1149;1399.47,787.8691;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1216;1290.083,502.3752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;1148;2300.79,618.5721;Inherit;False;1137;Specular;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1225;2629.366,176.6645;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;1150;2497.079,420.4208;Inherit;True;4;4;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;1165;2536.236,937.0959;Inherit;False;-1;;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;1181;1596.995,1351.613;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1170;1788.995,1351.613;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;1214;1539.587,374.6937;Inherit;True;Property;_Keyword0;Keyword 0;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1167;1946.573,951.9242;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;1161;1698.91,759.2792;Float;False;Property;_Wind;Wind;7;0;Create;True;0;0;0;False;0;False;1;1;1;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector3Node;1179;1340.995,1351.613;Inherit;False;Property;_SnowCoverage;SnowCoverage;27;0;Create;True;0;0;0;False;0;False;0,0.38,0;0,0.38,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;1222;2759.201,290.3403;Inherit;True;Property;_Keyword0;Keyword 0;33;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1168;2968.37,1342.849;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;1182;1618.84,958.3712;Inherit;False;Constant;_Vector0;Vector 0;12;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;1164;2541.995,1287.613;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;1178;1324.995,1191.613;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;1160;3251.468,1359.548;Inherit;False;Snow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;1177;2268.995,1223.613;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;1158;2286.051,1495.613;Inherit;False;Property;_NoiseSnowOpacity;Noise Snow Opacity;22;0;Create;True;0;0;0;False;0;False;0.51;0.51;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;1153;2140.995,1591.613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;1169;2381.894,874.5692;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;1152;2618.142,799.9822;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;1166;1340.995,1543.613;Inherit;False;Property;_SnowDir;SnowDir;23;0;Create;True;0;0;0;False;0;False;0,1,0;0.11,0.61,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;1163;2012.995,1223.613;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;1173;2092.557,1034.418;Inherit;False;DotSnow;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;1171;1996.995,1415.613;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;1155;1772.995,1175.613;Inherit;False;Property;_NoiseTile;Noise Tile;21;0;Create;True;0;0;0;False;0;False;5.6,7.28;5.6,7.28;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;1183;1628.995,1607.613;Float;False;Property;_SnowAmount;SnowAmount;19;0;Create;True;0;0;0;False;0;False;0;0;0;1.38;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;1157;2428.995,1607.613;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2904.697,598.8361;Float;False;True;-1;2;;0;0;CustomLighting;IL3DN/Pine2;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.3;True;True;0;True;TreeTransparentCutout;;Geometry;All;9;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;metal;xboxone;ps4;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;892;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1038;0;1037;0
WireConnection;1041;0;1038;0
WireConnection;1044;0;1042;0
WireConnection;1043;0;1041;0
WireConnection;1043;1;1039;0
WireConnection;1043;2;1040;0
WireConnection;1046;0;1044;0
WireConnection;1046;2;1043;0
WireConnection;1047;0;1046;0
WireConnection;1047;1;1045;0
WireConnection;1048;0;1047;0
WireConnection;1052;1;1048;0
WireConnection;1055;0;1053;0
WireConnection;1054;0;1052;0
WireConnection;1054;1;1050;0
WireConnection;1054;2;1051;0
WireConnection;1057;0;1055;0
WireConnection;1056;0;1054;0
WireConnection;1061;0;1057;0
WireConnection;1064;1;1059;0
WireConnection;1067;0;1063;0
WireConnection;1067;1;1062;0
WireConnection;1075;0;1072;0
WireConnection;1075;1;1067;0
WireConnection;1071;0;1064;0
WireConnection;1071;1;1065;2
WireConnection;1076;0;1066;0
WireConnection;1076;1;1070;0
WireConnection;1073;0;1071;0
WireConnection;1073;1;1069;0
WireConnection;1073;2;1068;0
WireConnection;1081;0;1075;0
WireConnection;1080;0;1077;0
WireConnection;1080;1;1076;0
WireConnection;1084;0;1080;0
WireConnection;1084;1;1077;0
WireConnection;1086;0;1081;0
WireConnection;1086;1;1082;0
WireConnection;1079;0;1074;0
WireConnection;1079;2;1073;0
WireConnection;1090;0;1086;0
WireConnection;1090;1;1087;0
WireConnection;1083;1;1078;0
WireConnection;1083;0;1079;0
WireConnection;1199;0;1198;0
WireConnection;1210;0;1209;0
WireConnection;1089;0;1084;0
WireConnection;1089;1;1085;0
WireConnection;1195;0;1196;0
WireConnection;1195;1;1226;0
WireConnection;1098;0;1188;0
WireConnection;1098;1;1093;0
WireConnection;1197;0;1195;0
WireConnection;1197;3;1199;0
WireConnection;1197;4;1198;0
WireConnection;1102;0;1089;0
WireConnection;1102;1;1092;0
WireConnection;1101;0;1187;0
WireConnection;1101;1;1094;0
WireConnection;1088;0;1083;0
WireConnection;1227;1;1210;0
WireConnection;1227;0;1210;1
WireConnection;1227;2;1210;2
WireConnection;1100;0;1090;0
WireConnection;1100;1;1095;0
WireConnection;1096;0;1091;0
WireConnection;1217;0;1227;0
WireConnection;1217;1;1218;0
WireConnection;1107;0;1100;0
WireConnection;1107;1;1101;0
WireConnection;1103;0;1102;0
WireConnection;1103;1;1098;0
WireConnection;1207;0;1197;0
WireConnection;1207;1;1208;0
WireConnection;1115;0;1103;0
WireConnection;1104;0;1096;0
WireConnection;1104;1;1097;0
WireConnection;1106;1;1099;0
WireConnection;1219;0;1207;0
WireConnection;1219;1;1217;0
WireConnection;1116;0;1107;0
WireConnection;1111;0;1105;0
WireConnection;1111;1;1106;4
WireConnection;1220;0;1219;0
WireConnection;1220;1;1221;0
WireConnection;1110;0;1104;0
WireConnection;1122;0;1115;0
WireConnection;1122;1;1118;0
WireConnection;1121;0;1114;0
WireConnection;1121;1;1119;2
WireConnection;1211;0;1227;0
WireConnection;1211;1;1207;0
WireConnection;1123;0;1117;4
WireConnection;1123;1;1114;0
WireConnection;1120;0;1116;0
WireConnection;1120;1;1113;0
WireConnection;1134;0;1120;0
WireConnection;1126;0;1111;0
WireConnection;1126;1;1109;0
WireConnection;1126;2;1110;0
WireConnection;1212;0;1211;0
WireConnection;1223;0;1220;0
WireConnection;1130;0;1123;0
WireConnection;1130;1;1121;0
WireConnection;1129;0;1122;0
WireConnection;1133;0;1126;0
WireConnection;1135;0;1037;0
WireConnection;1135;1;1130;0
WireConnection;1137;0;1129;0
WireConnection;1138;0;1134;0
WireConnection;1194;0;1133;0
WireConnection;1143;0;1189;0
WireConnection;1143;1;1190;0
WireConnection;1145;0;1140;0
WireConnection;1145;1;1139;1
WireConnection;1149;0;1135;0
WireConnection;1216;0;1106;4
WireConnection;1216;1;1213;0
WireConnection;1225;0;1224;0
WireConnection;1225;1;1191;0
WireConnection;1150;0;1194;0
WireConnection;1150;1;1147;0
WireConnection;1150;2;1148;0
WireConnection;1150;3;1143;0
WireConnection;1181;0;1178;0
WireConnection;1181;1;1179;2
WireConnection;1170;0;1181;0
WireConnection;1170;1;1183;0
WireConnection;1214;1;1106;4
WireConnection;1214;0;1216;0
WireConnection;1167;0;1178;0
WireConnection;1167;1;1182;0
WireConnection;1161;0;1149;0
WireConnection;1222;1;1191;0
WireConnection;1222;0;1225;0
WireConnection;1168;0;1164;0
WireConnection;1168;1;1157;0
WireConnection;1164;0;1177;0
WireConnection;1164;1;1158;0
WireConnection;1160;0;1168;0
WireConnection;1177;0;1163;0
WireConnection;1153;0;1183;0
WireConnection;1153;1;1171;0
WireConnection;1152;0;1145;0
WireConnection;1163;0;1155;0
WireConnection;1173;0;1167;0
WireConnection;1171;0;1166;0
WireConnection;1171;1;1170;0
WireConnection;1157;0;1153;0
WireConnection;0;2;1222;0
WireConnection;0;10;1214;0
WireConnection;0;13;1150;0
WireConnection;0;11;1161;0
WireConnection;0;12;1152;0
ASEEND*/
//CHKSM=82D92C88B3F494CDA619BEA175D46F9F5765A2C7
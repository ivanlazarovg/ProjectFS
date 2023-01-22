// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "River"
{
	Properties
	{
		_WaveDirection("Wave Direction", Vector) = (0.18,0.43,0,0)
		_WaveSpeed("Wave Speed", Float) = 1
		_WaveTile("Wave Tile", Float) = 1
		_WaveStretch("Wave Stretch", Vector) = (0.2,0.73,0,0)
		_Tesselation("Tesselation", Float) = 0
		_Vector0("Vector 0", Vector) = (0,1,0,0)
		_WaveHeight("Wave Height", Float) = 0.5
		_Smoothness("Smoothness", Float) = 0.9
		_WaterColor("WaterColor", Color) = (0.1883677,0.4017064,0.7830189,0)
		_EdgeDistance("Edge Distance", Float) = 1
		_EdgeStrength("Edge Strength", Float) = 1
		_Normaltile("Normal tile", Float) = 0.88
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalDirection("Normal Direction", Vector) = (1,0,0,0)
		_NormalDirectionminus("Normal Direction minus", Vector) = (-1,0,0,0)
		_NormalSpeed("Normal Speed", Float) = 1
		_NormalScale("Normal Scale", Range( 0 , 1)) = 0.4641946
		_Texture0("Texture 0", 2D) = "white" {}
		_EdgeFoamTile("Edge Foam Tile", Float) = 1
		_RefractAmount("Refract Amount", Float) = 0.1
		_Depth("Depth", Float) = -4
		_RefractionColor("RefractionColor", Color) = (0.5896226,0.7647572,1,0)
		_WaterEdgeClamp("WaterEdgeClamp", Color) = (0,0,0,0)
		_DeepRefractionFactor("Deep Refraction Factor", Float) = 0
		_ReflectionTexture("Reflection Texture", CUBE) = "white" {}
		_DetailReflectionIntensity("Detail Reflection Intensity", Float) = 0
		_ReflectionIntensity("Reflection Intensity", Float) = 0
		_DetailReflectionTint("Detail Reflection Tint", Color) = (0,0,0,0)
		_ReflectionTint("Reflection Tint", Color) = (0,0,0,0)
		_DetailRelfectionTexture("Detail Relfection Texture", CUBE) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
		[Header(Forward Rendering Options)]
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma shader_feature _GLOSSYREFLECTIONS_OFF
		#if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
		#else
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
		#endif
		#pragma surface surf Standard alpha:fade keepalpha noshadow exclude_path:deferred vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform float3 _Vector0;
		uniform float _WaveHeight;
		uniform float _WaveSpeed;
		uniform float2 _WaveDirection;
		uniform float2 _WaveStretch;
		uniform float _WaveTile;
		uniform sampler2D _NormalMap;
		uniform float _NormalScale;
		uniform float2 _NormalDirection;
		uniform float _NormalSpeed;
		uniform float _Normaltile;
		uniform float2 _NormalDirectionminus;
		uniform float4 _WaterColor;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _EdgeDistance;
		uniform sampler2D _Texture0;
		uniform float _EdgeFoamTile;
		uniform float _EdgeStrength;
		ASE_DECLARE_SCREENSPACE_TEXTURE( _GrabTexture )
		uniform float _RefractAmount;
		uniform float4 _WaterEdgeClamp;
		uniform float _DeepRefractionFactor;
		uniform samplerCUBE _ReflectionTexture;
		uniform float4 _ReflectionTint;
		uniform float _ReflectionIntensity;
		uniform float4 _DetailReflectionTint;
		uniform samplerCUBE _DetailRelfectionTexture;
		uniform float _DetailReflectionIntensity;
		uniform float4 _RefractionColor;
		uniform float _Depth;
		uniform float _Smoothness;
		uniform float _Tesselation;


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


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			float4 temp_cast_3 = (_Tesselation).xxxx;
			return temp_cast_3;
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_3_0 = ( _Time.y * _WaveSpeed );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WaveWorldSpace11 = appendResult10;
			float4 WaveTiling21 = ( ( float4( _WaveStretch, 0.0 , 0.0 ) * WaveWorldSpace11 ) * _WaveTile );
			float2 panner6 = ( temp_output_3_0 * _WaveDirection + WaveTiling21.xy);
			float simplePerlin2D7 = snoise( panner6 );
			simplePerlin2D7 = simplePerlin2D7*0.5 + 0.5;
			float2 panner23 = ( temp_output_3_0 * _WaveDirection + ( WaveTiling21 * float4( 0.1,0.1,0,0 ) ).xy);
			float simplePerlin2D24 = snoise( panner23 );
			simplePerlin2D24 = simplePerlin2D24*0.5 + 0.5;
			float WaveHeightPattern159 = ( simplePerlin2D7 + simplePerlin2D24 );
			float3 WaveHeight32 = ( ( _Vector0 * _WaveHeight ) * WaveHeightPattern159 );
			v.vertex.xyz += WaveHeight32;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float4 appendResult10 = (float4(ase_worldPos.x , ase_worldPos.z , 0.0 , 0.0));
			float4 WaveWorldSpace11 = appendResult10;
			float4 temp_output_60_0 = ( WaveWorldSpace11 * _Normaltile );
			float2 panner63 = ( 1.0 * _Time.y * ( _NormalDirection * _NormalSpeed ) + temp_output_60_0.xy);
			float2 panner64 = ( 1.0 * _Time.y * ( _NormalDirectionminus * ( _NormalSpeed * 3.0 ) ) + ( temp_output_60_0 * ( _Normaltile * 5.0 ) ).xy);
			float3 Normals73 = BlendNormals( UnpackScaleNormal( tex2D( _NormalMap, panner63 ), _NormalScale ) , UnpackScaleNormal( tex2D( _NormalMap, panner64 ), _NormalScale ) );
			o.Normal = Normals73;
			float4 WaveColor43 = saturate( _WaterColor );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth46 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth46 = abs( ( screenDepth46 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _EdgeDistance ) );
			float4 WaveTiling21 = ( ( float4( _WaveStretch, 0.0 , 0.0 ) * WaveWorldSpace11 ) * _WaveTile );
			float4 Edge51 = saturate( ( ( ( 1.0 - distanceDepth46 ) + tex2D( _Texture0, ( ( WaveTiling21 / 10.0 ) * _EdgeFoamTile ).xy ) ) * _EdgeStrength ) );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor115 = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_GrabTexture,( float3( (ase_grabScreenPosNorm).xy ,  0.0 ) + ( _RefractAmount * Normals73 ) ).xy);
			float4 clampResult120 = clamp( screenColor115 , _WaterEdgeClamp , float4( 1,1,1,0 ) );
			float4 Refraction118 = clampResult120;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 temp_output_168_0 = reflect( ase_worldViewDir , Normals73 );
			float4 Reflection209 = saturate( ( ( ( texCUBE( _ReflectionTexture, temp_output_168_0 ) * _ReflectionTint ) * _ReflectionIntensity ) + ( ( _DetailReflectionTint * texCUBE( _DetailRelfectionTexture, temp_output_168_0 ) ) * _DetailReflectionIntensity ) ) );
			float screenDepth123 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth123 = abs( ( screenDepth123 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _Depth ) );
			float clampResult125 = clamp( ( 1.0 - distanceDepth123 ) , 0.0 , 1.0 );
			float Depth126 = clampResult125;
			float4 lerpResult127 = lerp( ( WaveColor43 + Edge51 + ( Refraction118 / _DeepRefractionFactor ) + Reflection209 ) , ( _RefractionColor + Refraction118 ) , Depth126);
			o.Albedo = lerpResult127.rgb;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17800
314;73;1172;506;1076.044;506.4669;2.147401;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;9;-3110.037,80.72633;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;10;-2859.803,116.7133;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-2575.042,121.7071;Inherit;False;WaveWorldSpace;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;74;-4641.731,-1875.894;Inherit;False;2544.311;781.4059;Sets the normal map movements and tilling;18;73;57;56;59;61;60;58;65;68;69;71;213;214;215;216;217;218;72;Normals;0.7673888,0.5364898,0.8301887,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-4544.342,-1825.894;Inherit;False;11;WaveWorldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-4443.021,-1589.037;Inherit;False;Property;_Normaltile;Normal tile;11;0;Create;True;0;0;False;0;0.88;0.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-4216.767,-1803.893;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;-4276.662,-1300.706;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-3891.326,-1551.531;Inherit;True;Property;_NormalSpeed;Normal Speed;15;0;Create;True;0;0;False;0;1;0.007;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-4127.69,-1504.052;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;217;-3928.741,-1321.546;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;65;-3912.094,-1720.13;Inherit;False;Property;_NormalDirection;Normal Direction;13;0;Create;True;0;0;False;0;1,0;5.38,-0.65;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TexturePropertyNode;57;-3096.684,-1545.295;Inherit;True;Property;_NormalMap;Normal Map;12;0;Create;True;0;0;False;0;4769e995b8ae8f14dbcb4d9eeef57a09;562098aa15953264e8099176fe6e5dc3;False;bump;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-3653.16,-1453.198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;66;-3908.067,-1258.488;Inherit;False;Property;_NormalDirectionminus;Normal Direction minus;14;0;Create;True;0;0;False;0;-1,0;23.94,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;214;-2889.087,-1571.828;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;215;-2886.789,-1379.529;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-3523.206,-1243.771;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;218;-3511.681,-1287.99;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-3633.855,-1697.13;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;216;-3100.221,-1359.215;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;213;-3161.087,-1594.828;Inherit;False;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;64;-3299.593,-1316.137;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;63;-3427.958,-1796.369;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;15;-3269.496,-609.3011;Inherit;False;Property;_WaveStretch;Wave Stretch;3;0;Create;True;0;0;False;0;0.2,0.73;0.19,0.05;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;72;-3460.602,-1522.327;Inherit;False;Property;_NormalScale;Normal Scale;16;0;Create;False;0;0;False;0;0.4641946;0.03637661;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;35;-3319.496,-707.3184;Inherit;False;1321.648;394.2285;Sets the proper tiling of the UVs;1;17;Wave UVs;1,0.3773603,0,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;13;-3146.709,-433.0899;Inherit;False;11;WaveWorldSpace;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-2670.966,-496.4857;Inherit;False;Property;_WaveTile;Wave Tile;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-2880.08,-657.3184;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;55;-3138.853,-1754.054;Inherit;True;Property;_TextureSample1;Texture Sample 1;13;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;56;-3058.628,-1318.805;Inherit;True;Property;_TextureSample2;Texture Sample 2;13;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;71;-2628.749,-1507.669;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-2509.89,-631.1459;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-2221.85,-571.6344;Inherit;False;WaveTiling;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-2175.569,-1517.905;Inherit;True;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;231;1659.742,-1123.084;Inherit;False;2122.716;959.6042;Comment;16;211;169;168;173;182;227;178;226;177;228;229;179;209;224;181;230;Reflection;0.2999733,0.5943396,0.426524,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-3308.242,1436.44;Inherit;True;21;WaveTiling;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-3276.688,1696.765;Inherit;False;Constant;_Float0;Float 0;20;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;169;1709.742,-1040.547;Inherit;True;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;211;1717.767,-712.494;Inherit;False;73;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1678.367,1630.282;Inherit;False;Property;_WaveSpeed;Wave Speed;1;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ReflectOpNode;168;2052.823,-750.3826;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1632.121,810.1876;Inherit;False;21;WaveTiling;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;1;-1719.706,1372.837;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;-3048.407,1723.86;Inherit;False;Property;_EdgeFoamTile;Edge Foam Tile;18;0;Create;True;0;0;False;0;1;-2.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-3508.443,619.5677;Inherit;False;Property;_EdgeDistance;Edge Distance;9;0;Create;True;0;0;False;0;1;0.04;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;83;-3020.217,1518.587;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;108;157.1336,-1783.96;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;113;14.21594,-1433.381;Inherit;True;73;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;110;77.46892,-1609.469;Inherit;False;Property;_RefractAmount;Refract Amount;20;0;Create;True;0;0;False;0;0.1;0.22;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;81;-2859.283,1514.703;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;230;2359.912,-375.4797;Inherit;False;Property;_DetailReflectionTint;Detail Reflection Tint;28;0;Create;True;0;0;False;0;0,0,0,0;0.8726415,1,0.9674199,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;181;2265.807,-858.835;Inherit;False;Property;_ReflectionTint;Reflection Tint;29;0;Create;True;0;0;False;0;0,0,0,0;0.5681738,0.9056604,0.8189666,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;173;2207.686,-1073.084;Inherit;True;Property;_ReflectionTexture;Reflection Texture;25;0;Create;True;0;0;False;0;-1;None;4f034f6e9b2f41240ace87ea18e9a367;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;224;2221.778,-652.6757;Inherit;True;Property;_DetailRelfectionTexture;Detail Relfection Texture;30;0;Create;True;0;0;False;0;-1;None;56a68e301a0ff55469ae441c0112d256;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-1423.502,955.335;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0.1,0.1,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1414.162,1428.645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;4;-1570.919,1120.087;Inherit;False;Property;_WaveDirection;Wave Direction;0;0;Create;True;0;0;False;0;0.18,0.43;2.74,-0.65;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DepthFade;46;-3231.866,593.4858;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;155;393.1668,-1664.288;Inherit;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;78;-3106.384,1206.341;Inherit;True;Property;_Texture0;Texture 0;17;0;Create;True;0;0;False;0;None;688a8db5ad3aeeb4f82771a3047f11b1;True;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;348.8669,-1559.235;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PannerNode;23;-1086.064,1288.521;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;227;2719.633,-490.5978;Inherit;False;Property;_DetailReflectionIntensity;Detail Reflection Intensity;26;0;Create;True;0;0;False;0;0;0.07;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;2659.17,-933.368;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;6;-1089.158,855.1807;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;146;147.1566,-1119.797;Inherit;False;1286.483;248.203;Comment;5;126;125;129;123;124;Depth Fade;1,0.3616316,0,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;48;-2847.528,607.0969;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;178;2718.472,-810.1492;Inherit;False;Property;_ReflectionIntensity;Reflection Intensity;27;0;Create;True;0;0;False;0;0;0.21;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;114;574.9116,-1600.38;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;79;-2703.268,1214.953;Inherit;True;Property;_TextureSample0;Texture Sample 0;19;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;2672.318,-666.3403;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;2924.103,-686.6186;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;177;2985.754,-879.5588;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;7;-676.0573,852.6127;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;24;-700.3303,1286.204;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2859.5,720.4877;Inherit;False;Property;_EdgeStrength;Edge Strength;10;0;Create;True;0;0;False;0;1;23.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-2338.19,1063.207;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;124;197.1566,-1056.907;Inherit;False;Property;_Depth;Depth;21;0;Create;True;0;0;False;0;-4;1.82;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-1834.395,-1868.443;Inherit;False;1179.097;893.8657;Creates and lerps the shallow and the deep colot;3;87;43;39;Water Color;0.1084906,0.5066006,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;147;821.7625,-1370.59;Inherit;False;Property;_WaterEdgeClamp;WaterEdgeClamp;23;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;115;816.2712,-1584.682;Inherit;False;Global;_GrabScreen0;Grab Screen 0;22;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;123;439.8639,-1069.797;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;39;-1164.002,-1570.683;Inherit;False;Property;_WaterColor;WaterColor;8;0;Create;True;0;0;False;0;0.1883677,0.4017064,0.7830189,0;0.1293306,0.3478781,0.3361647,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;120;1036.573,-1506.808;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;26;-323.0567,1107.428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;-2565.849,569.9197;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;3140.404,-749.1434;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-1760.401,-431.6426;Inherit;False;Property;_WaveHeight;Wave Height;6;0;Create;True;0;0;False;0;0.5;0.48;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;-50.55786,1281.622;Inherit;False;WaveHeightPattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;19;-1726.568,-649.6379;Inherit;False;Property;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;0,1,0;0,0.12,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;53;-2383.719,627.5959;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;87;-908.1888,-1570.653;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;1300.182,-1548.936;Inherit;True;Refraction;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;179;3348.828,-737.2856;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;129;710.2653,-1016.398;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-1415.721,-576.8438;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;209;3558.458,-713.639;Inherit;False;Reflection;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;160;-1513.808,-386.5456;Inherit;False;159;WaveHeightPattern;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;161;-122.5757,280.6391;Inherit;False;118;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;163;-166.1375,456.498;Inherit;False;Property;_DeepRefractionFactor;Deep Refraction Factor;24;0;Create;True;0;0;False;0;0;19.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;125;916.8394,-1042.987;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-852.2893,-1449.419;Inherit;False;WaveColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-2244.123,750.8353;Inherit;False;Edge;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;210;193.615,400.2798;Inherit;False;209;Reflection;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-112.0658,30.5037;Inherit;False;43;WaveColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-112.8146,145.7895;Inherit;False;51;Edge;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;1209.64,-987.5936;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1154.477,-463.8113;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;142;-98.79865,-303.7824;Inherit;False;Property;_RefractionColor;RefractionColor;22;0;Create;True;0;0;False;0;0.5896226,0.7647572,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;162;109.8801,249.1282;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;119;-118.7247,-91.9055;Inherit;False;118;Refraction;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-893.9514,-420.9014;Inherit;False;WaveHeight;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;339.3068,74.85581;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;309.5503,-78.73915;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;128;461.6849,314.4334;Inherit;False;126;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;106;-2475.353,2476.667;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.2;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;127;670.5862,69.90393;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;104;-2058.874,2406.894;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-3464.988,2675.99;Inherit;False;Constant;_Float2;Float 2;21;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2338.637,2359.279;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;97;-2699.032,2467.984;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-3513.366,2116.734;Inherit;True;21;WaveTiling;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-3190.839,2602.558;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3413.376,2411.573;Inherit;False;Constant;_Float1;Float 1;20;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;98;-2977.546,2517.369;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.4,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-1992.712,2207.869;Inherit;False;Foam;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-2913.222,2193.653;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;88;-2718.839,2172.569;Inherit;True;Property;_TextureSample3;Texture Sample 3;20;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;90;-3125.914,2214.789;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;1000.586,248.6885;Inherit;False;73;Normals;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;1065.639,604.7246;Inherit;False;32;WaveHeight;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-18.2395,1111.604;Inherit;False;WavePattern;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;941.3187,339.7852;Inherit;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0.9;-0.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;1046.627,521.9853;Inherit;False;Property;_Tesselation;Tesselation;4;0;Create;True;0;0;False;0;0;165.46;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-3102.346,2402.81;Inherit;False;Property;_Float3;Float 3;19;0;Create;True;0;0;False;0;1;10.29;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1265.206,186.3094;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;River;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;True;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;6;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;105;-3563.366,2066.734;Inherit;False;1794.654;725.2561;Comment;0;Foam Mask;0.603183,0.5887327,0.9245283,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;86;-3358.242,1013.207;Inherit;False;1172.052;826.6523;Comment;0;Edge Foam;0.6273585,0.8323034,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;54;-3558.443,524.0104;Inherit;False;1511.727;312.4773;Sets the Edge dist, strength of the water;0;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;12;-3160.036,30.72639;Inherit;False;823.9971;268.9871;World Space UVs;0;World Space UVs;0.764151,0.371262,0.4938813,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;27;-1769.706,759.9112;Inherit;False;1598.649;986.371;Wave tilling and other sruff;0;Wave Pattern;0.5330188,1,0.8543309,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;121;-65.60962,-1851.053;Inherit;False;1617.226;544.5671;Comment;0;Refraction;1,0.8272087,0.08962262,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;34;-1810.401,-699.638;Inherit;False;1140.449;500.0785;Sets the Height of the waves;0;Wave Height;0.1691588,0.06857423,0.6320754,1;0;0
WireConnection;10;0;9;1
WireConnection;10;1;9;3
WireConnection;11;0;10;0
WireConnection;60;0;58;0
WireConnection;60;1;59;0
WireConnection;61;0;59;0
WireConnection;62;0;60;0
WireConnection;62;1;61;0
WireConnection;217;0;62;0
WireConnection;69;0;68;0
WireConnection;214;0;57;0
WireConnection;215;0;57;0
WireConnection;70;0;66;0
WireConnection;70;1;69;0
WireConnection;218;0;217;0
WireConnection;67;0;65;0
WireConnection;67;1;68;0
WireConnection;216;0;215;0
WireConnection;213;0;214;0
WireConnection;64;0;218;0
WireConnection;64;2;70;0
WireConnection;63;0;60;0
WireConnection;63;2;67;0
WireConnection;14;0;15;0
WireConnection;14;1;13;0
WireConnection;55;0;213;0
WireConnection;55;1;63;0
WireConnection;55;5;72;0
WireConnection;56;0;216;0
WireConnection;56;1;64;0
WireConnection;56;5;72;0
WireConnection;71;0;55;0
WireConnection;71;1;56;0
WireConnection;16;0;14;0
WireConnection;16;1;17;0
WireConnection;21;0;16;0
WireConnection;73;0;71;0
WireConnection;168;0;169;0
WireConnection;168;1;211;0
WireConnection;83;0;80;0
WireConnection;83;1;84;0
WireConnection;81;0;83;0
WireConnection;81;1;82;0
WireConnection;173;1;168;0
WireConnection;224;1;168;0
WireConnection;25;0;22;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;46;0;47;0
WireConnection;155;0;108;0
WireConnection;112;0;110;0
WireConnection;112;1;113;0
WireConnection;23;0;25;0
WireConnection;23;2;4;0
WireConnection;23;1;3;0
WireConnection;182;0;173;0
WireConnection;182;1;181;0
WireConnection;6;0;22;0
WireConnection;6;2;4;0
WireConnection;6;1;3;0
WireConnection;48;0;46;0
WireConnection;114;0;155;0
WireConnection;114;1;112;0
WireConnection;79;0;78;0
WireConnection;79;1;81;0
WireConnection;226;0;230;0
WireConnection;226;1;224;0
WireConnection;228;0;226;0
WireConnection;228;1;227;0
WireConnection;177;0;182;0
WireConnection;177;1;178;0
WireConnection;7;0;6;0
WireConnection;24;0;23;0
WireConnection;85;0;48;0
WireConnection;85;1;79;0
WireConnection;115;0;114;0
WireConnection;123;0;124;0
WireConnection;120;0;115;0
WireConnection;120;1;147;0
WireConnection;26;0;7;0
WireConnection;26;1;24;0
WireConnection;49;0;85;0
WireConnection;49;1;50;0
WireConnection;229;0;177;0
WireConnection;229;1;228;0
WireConnection;159;0;26;0
WireConnection;53;0;49;0
WireConnection;87;0;39;0
WireConnection;118;0;120;0
WireConnection;179;0;229;0
WireConnection;129;0;123;0
WireConnection;20;0;19;0
WireConnection;20;1;29;0
WireConnection;209;0;179;0
WireConnection;125;0;129;0
WireConnection;43;0;87;0
WireConnection;51;0;53;0
WireConnection;126;0;125;0
WireConnection;30;0;20;0
WireConnection;30;1;160;0
WireConnection;162;0;161;0
WireConnection;162;1;163;0
WireConnection;32;0;30;0
WireConnection;77;0;44;0
WireConnection;77;1;52;0
WireConnection;77;2;162;0
WireConnection;77;3;210;0
WireConnection;143;0;142;0
WireConnection;143;1;119;0
WireConnection;106;0;97;0
WireConnection;127;0;77;0
WireConnection;127;1;143;0
WireConnection;127;2;128;0
WireConnection;104;0;103;0
WireConnection;103;0;88;1
WireConnection;103;1;106;0
WireConnection;97;0;98;0
WireConnection;99;0;89;0
WireConnection;99;1;100;0
WireConnection;98;0;99;0
WireConnection;94;0;104;0
WireConnection;91;0;90;0
WireConnection;91;1;92;0
WireConnection;88;0;78;0
WireConnection;88;1;91;0
WireConnection;90;0;89;0
WireConnection;90;1;93;0
WireConnection;28;0;7;0
WireConnection;0;0;127;0
WireConnection;0;1;208;0
WireConnection;0;4;36;0
WireConnection;0;11;33;0
WireConnection;0;14;18;0
ASEEND*/
//CHKSM=99F656D3FF4190178BFC7471B7B18FC6EE41A28F
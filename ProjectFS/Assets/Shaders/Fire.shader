// Made with Amplify Shader Editor v1.9.1.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Fire"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_GradientNoiseScale("GradientNoiseScale", Float) = 12.36
		_GradientNoisePanSpeed("GradientNoisePanSpeed", Vector) = (0,-1,0,0)
		_VoronoiNoisePanSpeed("VoronoiNoisePanSpeed", Vector) = (0.12,-1.36,0,0)
		_NoiseSmoothening("NoiseSmoothening", Float) = 1.02
		_VoronoiScale("VoronoiScale", Float) = 4.12
		_VoronoiPower("VoronoiPower", Float) = 0.52
		[HDR]_FireColorTop("FireColorTop", Color) = (0.8962264,0.120872,0,0)
		[HDR]_FireColorBottom("FireColorBottom", Color) = (1,0.3820239,0,0)
		_GradientHeight("GradientHeight", Range( -1 , 1)) = -1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard alpha:fade keepalpha noshadow 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 uv_texcoord;
			float3 worldPos;
		};

		uniform float _VoronoiScale;
		uniform float2 _VoronoiNoisePanSpeed;
		uniform float _VoronoiPower;
		uniform float2 _GradientNoisePanSpeed;
		uniform float _GradientNoiseScale;
		uniform sampler2D _TextureSample0;
		uniform float _NoiseSmoothening;
		uniform float4 _FireColorTop;
		uniform float4 _FireColorBottom;
		uniform float _GradientHeight;


		float2 voronoihash15( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi15( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash15( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 //		if( d<F1 ) {
			 //			F2 = F1;
			 			float h = smoothstep(0.0, 1.0, 0.5 + 0.5 * (F1 - d) / smoothness); F1 = lerp(F1, d, h) - smoothness * h * (1.0 - h);mg = g; mr = r; id = o;
			 //		} else if( d<F2 ) {
			 //			F2 = d;
			
			 //		}
			 	}
			}
			return F1;
		}


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


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float time15 = 1.41;
			float2 voronoiSmoothId15 = 0;
			float voronoiSmooth15 = 0.0;
			float2 panner12 = ( _Time.y * _VoronoiNoisePanSpeed + i.uv_texcoord.xy);
			float2 coords15 = panner12 * _VoronoiScale;
			float2 id15 = 0;
			float2 uv15 = 0;
			float fade15 = 0.5;
			float voroi15 = 0;
			float rest15 = 0;
			for( int it15 = 0; it15 <2; it15++ ){
			voroi15 += fade15 * voronoi15( coords15, time15, id15, uv15, voronoiSmooth15,voronoiSmoothId15 );
			rest15 += fade15;
			coords15 *= 2;
			fade15 *= 0.5;
			}//Voronoi15
			voroi15 /= rest15;
			float saferPower20 = abs( voroi15 );
			float2 panner5 = ( _Time.y * _GradientNoisePanSpeed + i.uv_texcoord.xy);
			float gradientNoise2 = UnityGradientNoise(panner5,_GradientNoiseScale);
			float4 temp_cast_0 = (gradientNoise2).xxxx;
			float4 lerpResult8 = lerp( i.uv_texcoord , temp_cast_0 , _NoiseSmoothening);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 lerpResult28 = lerp( _FireColorTop , _FireColorBottom , ( ase_vertex3Pos.y - _GradientHeight ));
			float4 temp_output_35_0 = ( ( ( pow( saferPower20 , _VoronoiPower ) * gradientNoise2 ) * tex2D( _TextureSample0, lerpResult8.xy ) ) * lerpResult28 );
			o.Emission = temp_output_35_0.rgb;
			o.Alpha = temp_output_35_0.r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19103
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-2086.163,716.5007;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;12;-1806.848,767.3095;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;5;-1899.167,309.8595;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1863.779,465.6512;Inherit;False;Property;_GradientNoiseScale;GradientNoiseScale;1;0;Create;True;0;0;0;False;0;False;12.36;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;-1351.357,127.7648;Inherit;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2204.695,213.9016;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;7;-2201.429,367.2081;Inherit;False;Property;_GradientNoisePanSpeed;GradientNoisePanSpeed;2;0;Create;True;0;0;0;False;0;False;0,-1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;6;-2175.138,527.2953;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1692.16,28.05688;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;10;-1676.54,210.6211;Inherit;False;Property;_NoiseSmoothening;NoiseSmoothening;4;0;Create;True;0;0;0;False;0;False;1.02;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;2;-1637.581,323.5536;Inherit;True;Gradient;False;True;2;0;FLOAT2;0,0;False;1;FLOAT;4.14;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;14;-2086.624,846.3095;Inherit;False;Property;_VoronoiNoisePanSpeed;VoronoiNoisePanSpeed;3;0;Create;True;0;0;0;False;0;False;0.12,-1.36;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleTimeNode;13;-2075.538,1003.679;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;16;-1810.211,938.1725;Inherit;False;Property;_VoronoiScale;VoronoiScale;5;0;Create;True;0;0;0;False;0;False;4.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;15;-1578.386,732.0349;Inherit;False;0;0;1;0;2;False;1;False;True;False;4;0;FLOAT2;0,0;False;1;FLOAT;1.41;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.PowerNode;20;-1173.185,733.1747;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1326.133,831.0359;Inherit;False;Property;_VoronoiPower;VoronoiPower;6;0;Create;True;0;0;0;False;0;False;0.52;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-992.266,515.5739;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-1066.246,134.4633;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;123f45c3e4b2db84bb4757b5abd7185d;123f45c3e4b2db84bb4757b5abd7185d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-491.043,318.1228;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-596.5253,1085.612;Inherit;False;Property;_GradientHeight;GradientHeight;9;0;Create;True;0;0;0;False;0;False;-1;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;-167.1026,598.6826;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;29;-579.7145,592.5969;Inherit;False;Property;_FireColorTop;FireColorTop;7;1;[HDR];Create;True;0;0;0;False;0;False;0.8962264,0.120872,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;47;-691.4285,912.177;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;31;-273.8871,956.3759;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;30;-502.4643,782.4297;Inherit;False;Property;_FireColorBottom;FireColorBottom;8;1;[HDR];Create;True;0;0;0;False;0;False;1,0.3820239,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-51.51138,317.0663;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;262.4293,268.7937;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;5;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;12;2;14;0
WireConnection;12;1;13;0
WireConnection;5;0;3;0
WireConnection;5;2;7;0
WireConnection;5;1;6;0
WireConnection;8;0;9;0
WireConnection;8;1;2;0
WireConnection;8;2;10;0
WireConnection;2;0;5;0
WireConnection;2;1;4;0
WireConnection;15;0;12;0
WireConnection;15;2;16;0
WireConnection;20;0;15;0
WireConnection;20;1;21;0
WireConnection;36;0;20;0
WireConnection;36;1;2;0
WireConnection;1;1;8;0
WireConnection;18;0;36;0
WireConnection;18;1;1;0
WireConnection;28;0;29;0
WireConnection;28;1;30;0
WireConnection;28;2;31;0
WireConnection;31;0;47;2
WireConnection;31;1;32;0
WireConnection;35;0;18;0
WireConnection;35;1;28;0
WireConnection;0;2;35;0
WireConnection;0;9;35;0
ASEEND*/
//CHKSM=16D54D0749B69EC84EC2EE0AA2B8B7928441C34B
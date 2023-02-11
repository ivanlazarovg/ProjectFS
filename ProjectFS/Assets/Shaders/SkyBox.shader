// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "SkyBox"
{
	Properties
	{
		_HorizonExponent("HorizonExponent", Float) = 9.37
		_SkyColor4("SkyColor4", Color) = (0,0.6315789,1,0)
		_SkyGradientPower("Sky Gradient Power", Float) = 4.92
		_SkyColor2("SkyColor2", Color) = (0.8915094,0.9452381,1,0)
		_HorizonMaxRemap("HorizonMaxRemap", Float) = 1
		_SkyGradientScale("Sky Gradient Scale", Float) = 0.6
		_HorizonMinRemap("HorizonMinRemap", Float) = 0
		_HorizonColor("HorizonColor", Color) = (0.1657174,0.4188729,0.7169812,0)
		_HorizonGlowIntensity("Horizon Glow Intensity", Float) = 0.78
		_HorizonSharpness("Horizon Sharpness", Float) = 5.25
		_SunColor("SunColor", Color) = (1,0.8997817,0.75,0)
		_SunRadius("_SunRadius", Range( 0 , 2)) = 0.7466335
		_HorizonSunGlowSpreadMin("Horizon Sun Glow Spread Min", Range( 0 , 10)) = 3.782427
		_SunIntensity("SunIntensity", Float) = 1.1
		_HorizonSunGlowSpreadMax("Horizon Sun Glow Spread Max", Range( 0 , 10)) = 2.58169
		_HorizonLineColor("HorizonLineColor", Color) = (1,1,1,0)
		_TextureSample0("Texture Sample 0", CUBE) = "white" {}
		_StarLayer1Intensity("StarLayer1Intensity", Float) = 0
		_StarLayer3Intensity("StarLayer3Intensity", Float) = 0
		_StarLayer2Intensity("StarLayer2Intensity", Float) = 0
		_StarSize("StarSize", Vector) = (0,0,0,0)
		_StarLayer2Color("StarLayer2Color", Color) = (0,0,0,0)
		_StarLayer1Color("StarLayer1Color", Color) = (0,0,0,0)
		_StarLayer3Color("StarLayer3Color", Color) = (0,0,0,0)
		_StarsLightRotationX("StarsLightRotationX", Float) = 0
		_StarsLightRotationY("StarsLightRotationY", Float) = 0
		_moondirection("moondirection", Vector) = (1,1,1,0)
		_moonSize("moonSize", Float) = 0
		_MoonColor("MoonColor", Color) = (0,0,0,0)
		_MoonIntensity("MoonIntensity", Float) = 0
		_MoonOpacity("MoonOpacity", Float) = 0

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		Cull Off
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				float4 ase_texcoord1 : TEXCOORD1;
			};

			//This is a late directive
			
			uniform float4 _SkyColor4;
			uniform float4 _SkyColor2;
			uniform float _SkyGradientPower;
			uniform float _SkyGradientScale;
			uniform float4 _HorizonLineColor;
			uniform float _HorizonSharpness;
			uniform float _HorizonSunGlowSpreadMin;
			uniform float _HorizonSunGlowSpreadMax;
			uniform float _HorizonMinRemap;
			uniform float _HorizonMaxRemap;
			uniform float _HorizonExponent;
			uniform float _HorizonGlowIntensity;
			uniform float4 _HorizonColor;
			uniform float _SunRadius;
			uniform float _SunIntensity;
			uniform float4 _SunColor;
			uniform samplerCUBE _TextureSample0;
			uniform float _StarsLightRotationX;
			uniform float _StarsLightRotationY;
			uniform float _StarLayer1Intensity;
			uniform float3 _StarSize;
			uniform float4 _StarLayer1Color;
			uniform float _StarLayer2Intensity;
			uniform float4 _StarLayer2Color;
			uniform float _StarLayer3Intensity;
			uniform float4 _StarLayer3Color;
			uniform float3 _moondirection;
			uniform float _moonSize;
			uniform float _MoonIntensity;
			uniform float4 _MoonColor;
			uniform float _MoonOpacity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float2 appendResult32_g1 = (float2(( _StarsLightRotationX * _Time.y ) , ( _Time.y * _StarsLightRotationY )));
				float2 break8_g1 = radians( appendResult32_g1 );
				float temp_output_13_0_g1 = cos( break8_g1.x );
				float temp_output_9_0_g1 = sin( break8_g1.x );
				float3 appendResult16_g1 = (float3(temp_output_13_0_g1 , 0.0 , -temp_output_9_0_g1));
				float3 appendResult18_g1 = (float3(0.0 , 1.0 , 0.0));
				float3 appendResult19_g1 = (float3(temp_output_9_0_g1 , 0.0 , temp_output_13_0_g1));
				float3 appendResult15_g1 = (float3(1.0 , 0.0 , 0.0));
				float temp_output_12_0_g1 = cos( break8_g1.y );
				float temp_output_10_0_g1 = sin( break8_g1.y );
				float3 appendResult20_g1 = (float3(0.0 , temp_output_12_0_g1 , -temp_output_10_0_g1));
				float3 appendResult17_g1 = (float3(0.0 , temp_output_10_0_g1 , temp_output_12_0_g1));
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 normalizeResult25_g1 = normalize( ase_worldPos );
				float3 vertexToFrag27_g1 = mul( mul( float3x3(appendResult16_g1, appendResult18_g1, appendResult19_g1), float3x3(appendResult15_g1, appendResult20_g1, appendResult17_g1) ), normalizeResult25_g1 );
				o.ase_texcoord1.xyz = vertexToFrag27_g1;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
#endif
				float3 normalizeResult169 = normalize( WorldPosition );
				float dotResult170 = dot( normalizeResult169 , float3( 0,1,0 ) );
				float4 lerpResult174 = lerp( _SkyColor4 , _SkyColor2 , saturate( ( pow( ( 1.0 - abs( dotResult170 ) ) , _SkyGradientPower ) * _SkyGradientScale ) ));
				float4 SkyColour177 = lerpResult174;
				float3 normalizeResult143 = normalize( WorldPosition );
				float dotResult144 = dot( normalizeResult143 , float3( 0,1,0 ) );
				float3 worldSpaceLightDir = UnityWorldSpaceLightDir(WorldPosition);
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult156 = dot( -worldSpaceLightDir , ase_worldViewDir );
				float SunLightDirection159 = dotResult156;
				float clampResult109 = clamp( (_HorizonMinRemap + (SunLightDirection159 - ( 1.0 - pow( min( _HorizonSunGlowSpreadMin , _HorizonSunGlowSpreadMax ) , 2.0 ) )) * (_HorizonMaxRemap - _HorizonMinRemap) / (( 1.0 - pow( max( _HorizonSunGlowSpreadMin , _HorizonSunGlowSpreadMax ) , 2.0 ) ) - ( 1.0 - pow( min( _HorizonSunGlowSpreadMin , _HorizonSunGlowSpreadMax ) , 2.0 ) ))) , 0.0 , 1.0 );
				float saferPower114 = max( ( 1.0 - clampResult109 ) , 0.0001 );
				float dotResult108 = dot( worldSpaceLightDir , float3( 0,-1,0 ) );
				float clampResult110 = clamp( dotResult108 , 0.0 , 1.0 );
				float4 Horizon162 = ( saturate( pow( ( 1.0 - abs( dotResult144 ) ) , _HorizonSharpness ) ) * saturate( ( pow( saferPower114 , _HorizonExponent ) * _HorizonGlowIntensity * ( 1.0 - clampResult110 ) ) ) * _HorizonColor );
				float4 lerpResult180 = lerp( SkyColour177 , _HorizonLineColor , Horizon162);
				float3 normalizeResult89 = normalize( WorldPosition );
				float4 Sun92 = ( saturate( ( ( 1.0 - ( distance( normalizeResult89 , worldSpaceLightDir ) / _SunRadius ) ) * _SunIntensity ) ) * _SunColor );
				float3 vertexToFrag27_g1 = i.ase_texcoord1.xyz;
				float4 texCUBENode184 = texCUBE( _TextureSample0, vertexToFrag27_g1 );
				float4 Stars197 = saturate( ( ( pow( ( texCUBENode184.r * _StarLayer1Intensity ) , _StarSize.x ) * _StarLayer1Color ) + ( pow( ( texCUBENode184.g * _StarLayer2Intensity ) , _StarSize.y ) * _StarLayer2Color ) + ( pow( ( texCUBENode184.b * _StarLayer3Intensity ) , _StarSize.z ) * _StarLayer3Color ) ) );
				float3 normalizeResult228 = normalize( WorldPosition );
				float dotResult229 = dot( _moondirection , normalizeResult228 );
				float4 lerpResult242 = lerp( ( ( ( dotResult229 - _moonSize ) * _MoonIntensity ) * _MoonColor ) , float4( 0,0,0,0 ) , _MoonOpacity);
				float4 Moon238 = saturate( lerpResult242 );
				
				
				finalColor = ( lerpResult180 + Sun92 + Stars197 + Moon238 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=17800
186.0013;127.4603;1079;530;4804.424;1052.023;9.076717;True;False
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;155;-650.2987,1333.566;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;157;-649.8661,1477.442;Float;True;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NegateNode;158;-387.2305,1464.547;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-540.4204,-922.3973;Float;False;Property;_HorizonSunGlowSpreadMin;Horizon Sun Glow Spread Min;12;0;Create;True;0;0;False;0;3.782427;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-549.4204,-833.3964;Float;False;Property;_HorizonSunGlowSpreadMax;Horizon Sun Glow Spread Max;14;0;Create;True;0;0;False;0;2.58169;1.79;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;102;-234.4224,-934.3973;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;101;-227.4214,-825.3964;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;156;-214.7076,1465.763;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;221;-66.82532,-944.4604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;222;-55.82532,-811.4604;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;159;199.1329,1479.778;Float;False;SunLightDirection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;120;124.6216,-795.2963;Float;False;Property;_HorizonMinRemap;HorizonMinRemap;6;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;142;-227.8177,-1245.249;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;118;105.1216,-955.1964;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;164;1214.265,363.8713;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;105;51.57764,-1066.378;Inherit;False;159;SunLightDirection;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;119;109.5234,-875.0963;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;127.2217,-709.7963;Float;False;Property;_HorizonMaxRemap;HorizonMaxRemap;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;143;14.87961,-1246.937;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;169;1427.643,372.2434;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TFHCRemapNode;106;352.7095,-994.73;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;107;371.1494,-727.2903;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;217;-1924.495,166.98;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;216;-1934.495,327.98;Inherit;False;Property;_StarsLightRotationY;StarsLightRotationY;25;0;Create;True;0;0;False;0;0;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;108;613.2334,-725.6223;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,-1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;170;1567.182,360.7864;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;144;243.0769,-1215.238;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,1,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;215;-1935.8,7.776152;Inherit;False;Property;_StarsLightRotationX;StarsLightRotationX;24;0;Create;True;0;0;False;0;0;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;109;581.0444,-1003.065;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;112;744.5977,-1003.465;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;227;947.0187,2315.641;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-1702.496,78.98008;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;616.6465,-878.3654;Float;False;Property;_HorizonExponent;HorizonExponent;0;0;Create;True;0;0;False;0;9.37;7.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;1239.39,518.2647;Float;False;Property;_SkyGradientPower;Sky Gradient Power;2;0;Create;True;0;0;False;0;4.92;4.921074;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;168;1775.232,365.3215;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;145;429.4284,-1208.389;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;88;851.9553,1174.56;Inherit;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;110;744.9336,-731.4033;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;219;-1706.581,255.3123;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;115;839.1836,-854.2743;Float;False;Property;_HorizonGlowIntensity;Horizon Glow Intensity;8;0;Create;True;0;0;False;0;0.78;0.74;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;89;1147.823,1248.558;Inherit;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;114;947.5464,-1028.865;Inherit;True;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalizeNode;228;1216.059,2323.427;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;230;1243.288,2485.399;Inherit;False;Property;_moondirection;moondirection;26;0;Create;True;0;0;False;0;1,1,1;30.1,35.14,-22.1;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;147;486.2213,-1118.474;Float;False;Property;_HorizonSharpness;Horizon Sharpness;9;0;Create;True;0;0;False;0;5.25;1.982373;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;171;1981.542,351.2744;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;199;-1570.547,198.6387;Inherit;False;RotateCubemap2D;-1;;1;395373cb78b7852418d091b9daed3a57;0;2;28;FLOAT;0;False;29;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;146;621.1027,-1195.248;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;113;899.0605,-738.0743;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;99;1181.869,1532.497;Inherit;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;225;2106.059,564.7686;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;165;1248.597,612.6039;Float;False;Property;_SkyGradientScale;Sky Gradient Scale;5;0;Create;True;0;0;False;0;0.6;0.599;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;81;1467.176,1344.49;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;1572.538,1607.273;Inherit;False;Property;_SunRadius;_SunRadius;11;0;Create;True;0;0;False;0;0.7466335;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-1256.676,393.1294;Inherit;False;Property;_StarLayer3Intensity;StarLayer3Intensity;18;0;Create;True;0;0;False;0;0;0.6986358;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;226;2386.111,625.9294;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;148;786.6669,-1190.797;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;1167.704,-998.7062;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;184;-1291.272,-59.82955;Inherit;True;Property;_TextureSample0;Texture Sample 0;16;0;Create;True;0;0;False;0;-1;None;77520064aae579b48aa2e3d446f8c536;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;166;2180.318,340.4695;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-1261.413,165.1681;Inherit;False;Property;_StarLayer1Intensity;StarLayer1Intensity;17;0;Create;True;0;0;False;0;0;0.6986358;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;234;1679.553,2523.47;Inherit;False;Property;_moonSize;moonSize;27;0;Create;True;0;0;False;0;0;51.26;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;-1258.206,274.9769;Inherit;False;Property;_StarLayer2Intensity;StarLayer2Intensity;19;0;Create;True;0;0;False;0;0;0.6986358;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;229;1479.895,2431.372;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;117;1422.662,-1019.748;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;167;2456.877,343.4256;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-755.6478,316.4473;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;149;1031.287,-1216.147;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;194;-747.7028,527.2324;Inherit;False;Property;_StarSize;StarSize;20;0;Create;True;0;0;False;0;0,0,0;5.53,6.6,14;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;82;1910.972,1384.081;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;34;1484.468,-916.1014;Inherit;False;Property;_HorizonColor;HorizonColor;7;0;Create;True;0;0;False;0;0.1657174,0.4188729,0.7169812,0;0.7315496,0.3332924,0.4560414,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-755.6487,160.447;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-749.0858,19.23623;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;241;1972.021,2643.042;Inherit;False;Property;_MoonIntensity;MoonIntensity;29;0;Create;True;0;0;False;0;0;39.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;233;1843.553,2458.47;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;161;2212.475,121.9787;Inherit;False;Property;_SkyColor2;SkyColor2;3;0;Create;True;0;0;False;0;0.8915094,0.9452381,1,0;0.6711293,0.6556083,0.6592154,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;160;1650.853,-1136.634;Inherit;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;211;-406.157,479.5014;Inherit;False;Property;_StarLayer2Color;StarLayer2Color;21;0;Create;True;0;0;False;0;0,0,0,0;1,0.9103774,0.9130372,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;2308.473,1669.202;Inherit;False;Property;_SunIntensity;SunIntensity;13;0;Create;True;0;0;False;0;1.1;0.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;28;2240.259,-168.9613;Inherit;False;Property;_SkyColor4;SkyColor4;1;0;Create;True;0;0;False;0;0,0.6315789,1,0;0.316864,0.3368063,0.4896479,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;83;2236.306,1416.805;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;192;-431.187,179.0656;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;193;-432.9459,319.7392;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;212;-130.6146,643.3329;Inherit;False;Property;_StarLayer3Color;StarLayer3Color;23;0;Create;True;0;0;False;0;0,0,0,0;0.9938089,0.9009434,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;191;-428.0379,20.7213;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;210;-316.7668,-185.5743;Inherit;False;Property;_StarLayer1Color;StarLayer1Color;22;0;Create;True;0;0;False;0;0,0,0,0;0.9009434,0.9284591,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;240;2158.103,2501.933;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;236;2340.938,2628.386;Inherit;False;Property;_MoonColor;MoonColor;28;0;Create;True;0;0;False;0;0,0,0,0;0.7503242,0.740566,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;173;2688.199,386.8124;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;-102.2694,314.5058;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-109.9768,182.2019;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;2533.416,1470.882;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;162;1970.563,-1096.63;Inherit;False;Horizon;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;174;2612.441,33.51955;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;243;2738.344,2655.772;Inherit;False;Property;_MoonOpacity;MoonOpacity;30;0;Create;True;0;0;False;0;0;0.9713711;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;209;-84.60666,78.34541;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;2536.427,2490.963;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;84;2812.362,1471.468;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;178;2917.891,255.6925;Inherit;False;Property;_HorizonLineColor;HorizonLineColor;15;0;Create;True;0;0;False;0;1,1,1,0;0.8406275,0.6166153,0.0009286702,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;179;2992.797,486.7677;Inherit;False;162;Horizon;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;76;2655.289,1756.016;Inherit;False;Property;_SunColor;SunColor;10;0;Create;True;0;0;False;0;1,0.8997817,0.75,0;1,0.1490194,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;195;116.019,197.0672;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;177;2936.194,81.68423;Inherit;False;SkyColour;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;242;2870.695,2522.971;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;180;3266.031,238.5872;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;3184.506,1598.955;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;196;275.3691,198.4178;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;237;3188.433,2556.287;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;197;444.949,241.2378;Inherit;False;Stars;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;3557.806,1595.138;Inherit;False;Sun;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;238;3408.504,2606.804;Inherit;False;Moon;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;224;3610.658,335.4395;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;93;3582.983,781.7884;Inherit;False;92;Sun;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;3766.622,952.7122;Inherit;False;197;Stars;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;239;4065.341,864.4833;Inherit;False;238;Moon;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;223;3648.713,601.8099;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;3920.451,596.5732;Inherit;True;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;98;4206.377,601.1635;Float;False;True;-1;2;ASEMaterialInspector;100;1;SkyBox;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;False;True;2;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;0
Node;AmplifyShaderEditor.CommentaryNode;244;897.0187,2265.641;Inherit;False;2735.486;574.7446;Comment;0;Moon;0.8066038,0.9219528,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;220;-1985.8,-235.5742;Inherit;False;2654.75;1090.907;Comment;0;Stars;0,0.02982672,0.3207547,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;175;1164.265,-146.1014;Inherit;False;2373.415;852.1724;Comment;0;SkyColor;0,0.5078261,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;176;-599.4204,-1296.937;Inherit;False;2793.983;752.6471;Comment;0;Horizon;1,0.6367924,0.874778,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;181;801.9553,1124.56;Inherit;False;2979.851;843.4559;Comment;0;SunDisk;1,0.9264809,0,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;182;-700.2987,1283.566;Inherit;False;1123.432;436.197;Comment;0;SunLightDirection;1,0.5135952,0,1;0;0
WireConnection;158;0;155;0
WireConnection;102;0;122;0
WireConnection;102;1;100;0
WireConnection;101;0;122;0
WireConnection;101;1;100;0
WireConnection;156;0;158;0
WireConnection;156;1;157;0
WireConnection;221;0;102;0
WireConnection;222;0;101;0
WireConnection;159;0;156;0
WireConnection;118;0;221;0
WireConnection;119;0;222;0
WireConnection;143;0;142;0
WireConnection;169;0;164;0
WireConnection;106;0;105;0
WireConnection;106;1;118;0
WireConnection;106;2;119;0
WireConnection;106;3;120;0
WireConnection;106;4;121;0
WireConnection;108;0;107;0
WireConnection;170;0;169;0
WireConnection;144;0;143;0
WireConnection;109;0;106;0
WireConnection;112;0;109;0
WireConnection;218;0;215;0
WireConnection;218;1;217;0
WireConnection;168;0;170;0
WireConnection;145;0;144;0
WireConnection;110;0;108;0
WireConnection;219;0;217;0
WireConnection;219;1;216;0
WireConnection;89;0;88;0
WireConnection;114;0;112;0
WireConnection;114;1;111;0
WireConnection;228;0;227;0
WireConnection;171;0;168;0
WireConnection;199;28;218;0
WireConnection;199;29;219;0
WireConnection;146;0;145;0
WireConnection;113;0;110;0
WireConnection;225;0;172;0
WireConnection;81;0;89;0
WireConnection;81;1;99;0
WireConnection;226;0;165;0
WireConnection;148;0;146;0
WireConnection;148;1;147;0
WireConnection;116;0;114;0
WireConnection;116;1;115;0
WireConnection;116;2;113;0
WireConnection;184;1;199;0
WireConnection;166;0;171;0
WireConnection;166;1;225;0
WireConnection;229;0;230;0
WireConnection;229;1;228;0
WireConnection;117;0;116;0
WireConnection;167;0;166;0
WireConnection;167;1;226;0
WireConnection;187;0;184;3
WireConnection;187;1;189;0
WireConnection;149;0;148;0
WireConnection;82;0;81;0
WireConnection;82;1;75;0
WireConnection;186;0;184;2
WireConnection;186;1;190;0
WireConnection;185;0;184;1
WireConnection;185;1;188;0
WireConnection;233;0;229;0
WireConnection;233;1;234;0
WireConnection;160;0;149;0
WireConnection;160;1;117;0
WireConnection;160;2;34;0
WireConnection;83;0;82;0
WireConnection;192;0;186;0
WireConnection;192;1;194;2
WireConnection;193;0;187;0
WireConnection;193;1;194;3
WireConnection;191;0;185;0
WireConnection;191;1;194;1
WireConnection;240;0;233;0
WireConnection;240;1;241;0
WireConnection;173;0;167;0
WireConnection;214;0;193;0
WireConnection;214;1;212;0
WireConnection;213;0;192;0
WireConnection;213;1;211;0
WireConnection;90;0;83;0
WireConnection;90;1;91;0
WireConnection;162;0;160;0
WireConnection;174;0;28;0
WireConnection;174;1;161;0
WireConnection;174;2;173;0
WireConnection;209;0;191;0
WireConnection;209;1;210;0
WireConnection;235;0;240;0
WireConnection;235;1;236;0
WireConnection;84;0;90;0
WireConnection;195;0;209;0
WireConnection;195;1;213;0
WireConnection;195;2;214;0
WireConnection;177;0;174;0
WireConnection;242;0;235;0
WireConnection;242;2;243;0
WireConnection;180;0;177;0
WireConnection;180;1;178;0
WireConnection;180;2;179;0
WireConnection;85;0;84;0
WireConnection;85;1;76;0
WireConnection;196;0;195;0
WireConnection;237;0;242;0
WireConnection;197;0;196;0
WireConnection;92;0;85;0
WireConnection;238;0;237;0
WireConnection;224;0;180;0
WireConnection;223;0;224;0
WireConnection;154;0;223;0
WireConnection;154;1;93;0
WireConnection;154;2;198;0
WireConnection;154;3;239;0
WireConnection;98;0;154;0
ASEEND*/
//CHKSM=EA745138B288BCFE10B7FA6BA1A2A455BE9251F9
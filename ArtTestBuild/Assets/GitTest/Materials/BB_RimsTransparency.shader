Shader "BB_RimsTransparency"
{
	Properties 
	{
_DiffuseMap("Diffuse map w alpha opacity", 2D) = "black" {}
_NormalMap("Tangent Based Noprmal Map", 2D) = "bump" {}
_EmmisiveMap("Emmisive map adds Glow effect", 2D) = "white" {}
_SpecularAndGloss("Specular Map w Gloss as alpha", 2D) = "black" {}
_rim_power("_rim_power", Range(0.1,3) ) = 1
_rim_light_color("_rim_light_color", Color) = (0.4626866,0.9253731,0.828306,1)

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Transparent"
"IgnoreProjector"="False"
"RenderType"="Transparent"

		}

		
Cull Off
ZWrite On
ZTest LEqual
ColorMask RGBA
Fog{
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor  addshadow alpha decal:blend vertex:vert
#pragma target 2.0


sampler2D _DiffuseMap;
sampler2D _NormalMap;
sampler2D _EmmisiveMap;
sampler2D _SpecularAndGloss;
float _rim_power;
float4 _rim_light_color;

			struct EditorSurfaceOutput {
				half3 Albedo;
				half3 Normal;
				half3 Emission;
				half3 Gloss;
				half Specular;
				half Alpha;
				half4 Custom;
			};
			
			inline half4 LightingBlinnPhongEditor_PrePass (EditorSurfaceOutput s, half4 light)
			{
half3 spec = light.a * s.Gloss;
half4 c;
c.rgb = (s.Albedo * light.rgb + light.rgb * spec);
c.a = s.Alpha;
return c;

			}

			inline half4 LightingBlinnPhongEditor (EditorSurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
			{
				half3 h = normalize (lightDir + viewDir);
				
				half diff = max (0, dot ( lightDir, s.Normal ));
				
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular*128.0);
				
				half4 res;
				res.rgb = _LightColor0.rgb * diff;
				res.w = spec * Luminance (_LightColor0.rgb);
				res *= atten * 2.0;

				return LightingBlinnPhongEditor_PrePass( s, res );
			}

			inline half4 LightingBlinnPhongEditor_DirLightmap (EditorSurfaceOutput s, fixed4 color, fixed4 scale, half3 viewDir, bool surfFuncWritesNormal, out half3 specColor)
			{
				UNITY_DIRBASIS
				half3 scalePerBasisVector;
				
				half3 lm = DirLightmapDiffuse (unity_DirBasis, color, scale, s.Normal, surfFuncWritesNormal, scalePerBasisVector);
				
				half3 lightDir = normalize (scalePerBasisVector.x * unity_DirBasis[0] + scalePerBasisVector.y * unity_DirBasis[1] + scalePerBasisVector.z * unity_DirBasis[2]);
				half3 h = normalize (lightDir + viewDir);
			
				float nh = max (0, dot (s.Normal, h));
				float spec = pow (nh, s.Specular * 128.0);
				
				// specColor used outside in the forward path, compiled out in prepass
				specColor = lm * _SpecColor.rgb * s.Gloss * spec;
				
				// spec from the alpha component is used to calculate specular
				// in the Lighting*_Prepass function, it's not used in forward
				return half4(lm, spec);
			}
			
			struct Input {
				float2 uv_DiffuseMap;
float2 uv_NormalMap;
float3 viewDir;
float2 uv_EmmisiveMap;
float2 uv_SpecularAndGloss;

			};

			void vert (inout appdata_full v, out Input o) {
float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);


			}
			

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
float4 Tex2D0=tex2D(_DiffuseMap,(IN.uv_DiffuseMap.xyxy).xy);
float4 Tex2DNormal0=float4(UnpackNormal( tex2D(_NormalMap,(IN.uv_NormalMap.xyxy).xy)).xyz, 1.0 );
float4 Fresnel0_1_NoInput = float4(0,0,1,1);
float4 Fresnel0=(1.0 - dot( normalize( float4( IN.viewDir.x, IN.viewDir.y,IN.viewDir.z,1.0 ).xyz), normalize( Fresnel0_1_NoInput.xyz ) )).xxxx;
float4 Pow0=pow(Fresnel0,_rim_power.xxxx);
float4 Tex2D2=tex2D(_EmmisiveMap,(IN.uv_EmmisiveMap.xyxy).xy);
float4 Multiply0=Tex2D2 * _rim_light_color;
float4 Multiply1=Pow0 * Multiply0;
float4 Tex2D1=tex2D(_SpecularAndGloss,(IN.uv_SpecularAndGloss.xyxy).xy);
float4 Master0_7_NoInput = float4(0,0,0,0);
float4 Master0_6_NoInput = float4(1,1,1,1);
o.Albedo = Tex2D0;
o.Normal = Tex2DNormal0;
o.Emission = Multiply1;
o.Specular = Tex2D1.aaaa;
o.Gloss = Tex2D1;
o.Alpha = Tex2D0.aaaa;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}
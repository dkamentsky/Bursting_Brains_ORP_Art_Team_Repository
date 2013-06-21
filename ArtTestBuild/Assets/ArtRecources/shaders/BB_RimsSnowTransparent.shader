Shader "BB_RimsSnowTransparency"
{
	Properties 
	{
_snowlevel("_snowlevel", Range(1,0) ) = 1
_snowfalloff("_snowfalloff", Range(0,1) ) = 0.5
_normalsnowcutoff("_normalsnowcutoff", Range(0,1) ) = 0
_snowdiffuse("_snowdiffuse", 2D) = "black" {}
_snowSpecGloss("_snowSpecGloss", 2D) = "black" {}
_rimpower("_rimpower", Range(0,10) ) = 0.5
_rimpfalloff("_rimpfalloff", Range(0,10) ) = 0.5
_rimcolor("_rimcolor", Color) = (0.633493,0.9328358,0.920276,1)
_diffuse("_diffuse", 2D) = "black" {}
_normalmap("_normalmap", 2D) = "bump" {}
_emmisive("_emmisive", 2D) = "black" {}
_specularGloss("_specularGloss", 2D) = "black" {}

	}
	
	SubShader 
	{
		Tags
		{
"Queue"="Transparent"
"IgnoreProjector"="False"
"RenderType"="Transparent"

		}

		
Cull Back
ZWrite On
ZTest LEqual
ColorMask RGBA
Fog{
}


		CGPROGRAM
#pragma surface surf BlinnPhongEditor  alpha decal:blend vertex:vert
#pragma target 3.0


float _snowlevel;
float _snowfalloff;
float _normalsnowcutoff;
sampler2D _snowdiffuse;
sampler2D _snowSpecGloss;
float _rimpower;
float _rimpfalloff;
float4 _rimcolor;
sampler2D _diffuse;
sampler2D _normalmap;
sampler2D _emmisive;
sampler2D _specularGloss;

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
				float2 uv_snowdiffuse;
float2 uv_diffuse;
float3 sWorldNormal;
float2 uv_normalmap;
float2 uv_emmisive;
float2 uv_snowSpecGloss;
float2 uv_specularGloss;
float3 viewDir;

			};

			void vert (inout appdata_full v, out Input o) {
float4 VertexOutputMaster0_0_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_1_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_2_NoInput = float4(0,0,0,0);
float4 VertexOutputMaster0_3_NoInput = float4(0,0,0,0);

o.sWorldNormal = mul((float3x3)_Object2World, SCALED_NORMAL);

			}
			

			void surf (Input IN, inout EditorSurfaceOutput o) {
				o.Normal = float3(0.0,0.0,1.0);
				o.Alpha = 1.0;
				o.Albedo = 0.0;
				o.Emission = 0.0;
				o.Gloss = 0.0;
				o.Specular = 0.0;
				o.Custom = 0.0;
				
float4 Sampled2D0=tex2D(_snowdiffuse,IN.uv_snowdiffuse.xy);
float4 Sampled2D1=tex2D(_diffuse,IN.uv_diffuse.xy);
float4 Add0=float4( IN.sWorldNormal.x, IN.sWorldNormal.y,IN.sWorldNormal.z,1.0 ) + float4( 1.0, 1.0, 1.0, 1.0 );
float4 Divide0=Add0 / float4( 2,2,2,2 );
float4 Add3=Sampled2D0.aaaa + _snowfalloff.xxxx;
float4 Tex2DNormal0=float4(UnpackNormal( tex2D(_normalmap,(IN.uv_normalmap.xyxy).xy)).xyz, 1.0 );
float4 Split1=Tex2DNormal0;
float4 Multiply4=float4( Split1.z, Split1.z, Split1.z, Split1.z) * float4( -1,-1,-1,-1 );
float4 Multiply1=Multiply4 * _normalsnowcutoff.xxxx;
float4 Add2=Add3 + Multiply1;
float4 Multiply2=Add2 * float4( -1,-1,-1,-1 );
float4 Add1=Multiply2 + Divide0;
float4 Multiply3=Divide0 * Add1;
float4 Split0=Multiply3;
float4 Step0=step(float4( Split0.y, Split0.y, Split0.y, Split0.y),_snowlevel.xxxx);
float4 Lerp0=lerp(Sampled2D0,Sampled2D1,Step0);
float4 Sampled2D2=tex2D(_emmisive,IN.uv_emmisive.xy);
float4 Sampled2D3=tex2D(_snowSpecGloss,IN.uv_snowSpecGloss.xy);
float4 Sampled2D4=tex2D(_specularGloss,IN.uv_specularGloss.xy);
float4 Lerp1=lerp(Sampled2D3,Sampled2D4,Step0);
float4 Fresnel0_1_NoInput = float4(0,0,1,1);
float4 Fresnel0=(1.0 - dot( normalize( float4( IN.viewDir.x, IN.viewDir.y,IN.viewDir.z,1.0 ).xyz), normalize( Fresnel0_1_NoInput.xyz ) )).xxxx;
float4 Multiply0=Fresnel0 * _rimpower.xxxx;
float4 Pow0=pow(Multiply0,_rimpfalloff.xxxx);
float4 Lerp4=lerp(Lerp1,_rimcolor,Pow0);
float4 Master0_3_NoInput = float4(0,0,0,0);
float4 Master0_7_NoInput = float4(0,0,0,0);
float4 Master0_6_NoInput = float4(1,1,1,1);
o.Albedo = Lerp0;
o.Normal = Tex2DNormal0;
o.Emission = Sampled2D2;
o.Gloss = Lerp4;
o.Alpha = Sampled2D0.aaaa;

				o.Normal = normalize(o.Normal);
			}
		ENDCG
	}
	Fallback "Diffuse"
}
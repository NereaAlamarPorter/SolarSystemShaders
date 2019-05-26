Shader "Unlit/Rayado"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color1("Color1", Color) = (1.0,1.0,1.0,1.0)
		_Color2("Color2", Color) = (1.0,1.0,1.0,1.0)
		_Color3("Color3", Color) = (1.0,1.0,1.0,1.0)
		_Color4("Color4", Color) = (1.0,1.0,1.0,1.0)
		_Scale ("Scale", Float) = 1.0
		_Width ("Width", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color1;
			float4 _Color2;
			float4 _Color3;
			float4 _Color4;
			float _Scale;
			float _Width;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			


			fixed4 frag (v2f i) : SV_Target
			{
				float scaledT = frac(i.uv.y*_Scale);
				float s = step(_Width, scaledT);
				float4 rayablanca = lerp(float4(2.0, 2.0, 2.0, 1.0), _Color2, s);
				float lerpValue;
				if (i.uv.y > 1)
				{
					
					if (floor(i.uv.y) % 2 == 0)
					{
						lerpValue = 1 - (i.uv.y - floor(i.uv.y));
					}
					else
					{
						lerpValue = i.uv.y - floor(i.uv.y);
					}	
				}
				else
				{
					lerpValue = 1 - i.uv.y; 
				}
				float4 col1 = lerp(_Color3,_Color2,lerpValue);
				float4 col2 = lerp(_Color1, _Color2, lerpValue+_Scale);
				float4 col3 = lerp(_Color1, _Color2, lerpValue + _Scale+0.1);
				

				float3 texColor = float3(1.0, 1.0, 1.0)*tex2D(_MainTex , i.uv);


				return float4(texColor*(5*col3.xyz+col2.xyz+3*col1.xyz+rayablanca.xyz )/7,1.0);

			}
			ENDCG
		}
	}
}

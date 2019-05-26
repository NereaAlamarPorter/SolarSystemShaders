Shader "Unlit/anillo"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Cull Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{


			//Cubo en medio
			float2 copy_uv = i.uv;
			copy_uv -= 0.5;
			float r = 0.4;
			float d = length(copy_uv);
			float c = smoothstep(d - 0.1, d + 0.15, r);
			return float4(c+0.1, c-0.2,0.0, 1.0);

			return float4(c, c, c, 1.0);
			
			}
			ENDCG
		}
	}
}

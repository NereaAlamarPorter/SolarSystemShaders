Shader "Hidden/waving"
{
	Properties
	{
		_Timexd("Time", Float) = 0.0
		_Colorxd("Color", Vector) = (1, 1, 1)
		_Colordx("Color", Vector) = (1, 1, 1)
		_Numeritoxd("Numerito", Float) = 1.0
		_X("Seed X", float) = 1.0
		_Y("Seed Y", float) = 1.0
	}
		SubShader
	{
		Tags{ "RenderType" = "Transparent" "Queue" = "Transparent" }
		// No culling or depth
		Cull Back ZWrite Off ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float _Timexd;
			uniform float3 _Colorxd; 
			uniform float3 _Colordx;
			uniform float _Numeritoxd;
			float _X;
			float _Y;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 normal : NORMAL;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;
				return o;
			}

			float3 random3(float3 c) {
				float j = 4096.0*sin(dot(c, float3(17.0, 59.4, 15.0)));
				float3 r;
				r.z = frac(512.0*j);
				j *= .125;
				r.x = frac(512.0*j);
				j *= .125;
				r.y = frac(512.0*j);
				return r - 0.5;
			}

			const float F3 = 0.3333333;
			const float G3 = 0.1666667;

			float simplex3d(float3 p) {
				float3 s = floor(p + dot(p, float3(F3,F3,F3)));
				float3 x = p - s + dot(s, float3(G3, G3, G3));
				float3 e = step(float3(0.0,0.0,0.0), x - x.yzx);
				float3 i1 = e*(1.0 - e.zxy);
				float3 i2 = 1.0 - e.zxy*(1.0 - e);
				float3 x1 = x - i1 + G3;
				float3 x2 = x - i2 + 2.0*G3;
				float3 x3 = x - 1.0 + 3.0*G3;
				float4 w, d;
				w.x = dot(x, x);
				w.y = dot(x1, x1);
				w.z = dot(x2, x2);
				w.w = dot(x3, x3);
				w = max(0.6 - w, 0.0);
				d.x = dot(random3(s), x);
				d.y = dot(random3(s + i1), x1);
				d.z = dot(random3(s + i2), x2);
				d.w = dot(random3(s + 1.0), x3);
				w *= w;
				w *= w;
				d *= w;

				return dot(d, float4(52.0, 52.0, 52.0, 52.0));
			}

			float noise(float3 m) {
				return   0.5333333*simplex3d(m)
					+ 0.2666667*simplex3d(2.0*m)
					+ 0.1333333*simplex3d(4.0*m)
					+ 0.0666667*simplex3d(8.0*m);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;
				float2 uv_inv = float2(1.0 - i.uv[0], i.uv[1]);
				if (i.uv[0] * 2.0 > 1.0)
					uv = uv_inv;

				float2 uv_copy = uv;
				uv = uv * 2.0 - 1.0;

				uv_copy *= _Numeritoxd; //Gridsize
				uv_copy += float2(_X, _Y); //tile
				float3 uv_3 = float3(uv_copy.x, uv_copy.y, _Timexd);

				float ns = noise(uv_3*6.0+6.0);

				float y = abs(ns + uv[1])*sin(_Timexd);


				float g = pow(y, 0.3);

				float3 col = _Colorxd;
				col = col * -g + col;
				col = col * col;
				//col = col * col;


				return float4(col.x + _Colordx.x,col.y  + _Colordx.y,col.z + _Colordx.z, 1.0);
			}
			ENDCG
		}
	}
}

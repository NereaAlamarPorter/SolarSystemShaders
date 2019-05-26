﻿Shader "Perlin Noise"
{
	Properties
	{
		_GridSize("GridSize", float) = 10.0
		_X("Seed X", float) = 1.0
		_Y("Seed Y", float) = 1.0
		_Tex("Pattern", 2D) = "white" {} //Optional texture
	}

		SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardAdd" }

		Pass
	{
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		float4 permute(float4 x)
	{
		return fmod(34.0 * pow(x, 2) + x, 289.0);
	}

	float2 fade(float2 t) {
		return 6.0 * pow(t, 5.0) - 15.0 * pow(t, 4.0) + 10.0 * pow(t, 3.0);
	}

	float4 taylorInvSqrt(float4 r) {
		return 1.79284291400159 - 0.85373472095314 * r;
	}

#define DIV_289 0.00346020761245674740484429065744f

	float mod289(float x) {
		return x - floor(x * DIV_289) * 289.0;
	}

	float PerlinNoise2D(float2 P)
	{
		float4 Pi = floor(P.xyxy) + float4(0.0, 0.0, 1.0, 1.0);
		float4 Pf = frac(P.xyxy) - float4(0.0, 0.0, 1.0, 1.0);

		float4 ix = Pi.xzxz;
		float4 iy = Pi.yyww;
		float4 fx = Pf.xzxz;
		float4 fy = Pf.yyww;

		float4 i = permute(permute(ix) + iy);

		float4 gx = frac(i / 41.0) * 2.0 - 1.0;
		float4 gy = abs(gx) - 0.5;
		float4 tx = floor(gx + 0.5);
		gx = gx - tx;

		float2 g00 = float2(gx.x,gy.x);
		float2 g10 = float2(gx.y,gy.y);
		float2 g01 = float2(gx.z,gy.z);
		float2 g11 = float2(gx.w,gy.w);

		float4 norm = taylorInvSqrt(float4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
		g00 *= norm.x;
		g01 *= norm.y;
		g10 *= norm.z;
		g11 *= norm.w;

		float n00 = dot(g00, float2(fx.x, fy.x));
		float n10 = dot(g10, float2(fx.y, fy.y));
		float n01 = dot(g01, float2(fx.z, fy.z));
		float n11 = dot(g11, float2(fx.w, fy.w));

		float2 fade_xy = fade(Pf.xy);
		float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
		float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
		return 2.3 * n_xy;
	}

	float _GridSize;
	float _X;
	float _Y;
	uniform float4 _Color1;
	uniform float4 _Color2;
	sampler2D _Tex; //Used for texture
	float4 _Tex_ST; //For tiling


	struct appdata
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
	};

	struct v2f
	{
		float4 pos : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		float4 posWorld : TEXCOORD1;
	};

	v2f vert(appdata v)
	{
		v2f o;

		o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate the world position for our point
		o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
		o.pos = UnityObjectToClipPos(v.vertex); //And the position
		o.uv = TRANSFORM_TEX(v.uv, _Tex);

		return o;
	}

	fixed4 frag(v2f i) : COLOR
	{
		//Ambient light
		float3 ambient = float3(1.0,1.0,1.0);
		// Light direction
		float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
		float3 lightDir = normalize(fragmentToLightSource);
		//Normal direction
		float3 normal = normalize(i.normal);
		// Diffuse light
		float4 NdotL = max(0., dot(normal, lightDir) );
		float4 difuse = NdotL;
		float ns;

		float2 uvCopy = i.uv;
		float2 uvCopy_inv = float2(1.0-i.uv[0],i.uv[1]);
		if(2 * i.uv[0] > 1)
			uvCopy = uvCopy_inv;

		uvCopy *= _GridSize;
		uvCopy += float2(_X, _Y);

		ns = PerlinNoise2D(uvCopy) / 2 + 0.5f;

		float3 texColor = float3(1.0, 1.0, 1.0)*tex2D(_Tex, i.uv);
		float3 white = float3(1.0, 1.0, 1.0);

		return float4(((texColor - white)*ns + white)*(difuse*0.6 + ambient*0.4), 1.0);
	}
		ENDCG
	}
	}
}

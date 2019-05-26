// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Vertex Displacement" {
	Properties{
		_MainTex("Main Texture", 2D) = "white" {}
		_DisplacementTex("Displacement Texture", 2D) = "white" {}
		_MaxDisplacement("Max Displacement", Float) = 1.0
		_Col("Color", Color) = (1.0, 1.0, 1.0, 1.0)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardAdd" }
		Pass{
		CGPROGRAM

#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

		uniform sampler2D _MainTex;
		uniform sampler2D _DisplacementTex;
		uniform float _MaxDisplacement;
		float4 _Col;

	struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
	};

	struct vertexOutput {
		float4 position : SV_POSITION;
		float3 normal : NORMAL;
		float4 texcoord : TEXCOORD0;
		float4 posWorld : TEXCOORD1;
	};

	vertexOutput vert(vertexInput i) {
		vertexOutput o;

		float4 dispTexColor = tex2Dlod(_DisplacementTex, float4(i.texcoord.xy, 0.0, 0.0));
		float displacement = dispTexColor.rgb * _MaxDisplacement;

		float4 newVertexPos = i.vertex + float4(i.normal * displacement, 0.0);

		// output data            
		o.position = UnityObjectToClipPos(newVertexPos);
		o.texcoord = i.texcoord;
		o.posWorld = mul(unity_ObjectToWorld, i.vertex); //Calculate the world position for our point
		o.normal = normalize(mul(float4(i.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
		return o;

	}

	float4 frag(vertexOutput i) : COLOR
	{
		//Ambient light
		float3 ambient = float3(0.2,0.2,0.2);
		// Light direction
		float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
		float3 lightDir = normalize(fragmentToLightSource);
		//Normal direction
		float3 normal = normalize(i.normal);
		// Diffuse light
		float4 NdotL = max(0.1, dot(normal, lightDir));
		float4 difuse = NdotL;

		return _Col*_Col*float4(tex2D(_MainTex, i.texcoord.xy)*(difuse+ambient),1.0);
	}

		ENDCG
	}
	}
}
/*Structures we need for stages*/

struct VS_IN
{
	uint iv : SV_VertexID;
};

struct VS_OUT
{
    uint iv : VERTEXID;
};

struct HSC_OUT
{
    float edges[2] : SV_TessFactor;
}; 

struct GS_IN
{
    float4 Pos : POSITION; //width as w component
	float3 Dir : NORMAL0;
	float2 TexCd : TEXCOORD0;
	uint si:TEXCOORD1;
	
};

struct PS_IN
{
    float4 PosWVP : SV_Position;
	float3 Norm : NORMAL0;
	float2 TexCd : TEXCOORD0;
	uint si:TEXCOORD1;
};

struct GS_OUT
{
    float4 PosWVP : SV_Position;
	float3 Norm : NORMAL0;
	float2 TexCd : TEXCOORD0;
	uint iid : IID;
};
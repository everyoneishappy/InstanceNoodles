#include "..\..\Common\InstanceNoodles.fxh"
int instanceOffset;
StructuredBuffer<float> iidb;

float4x4 transform;

struct VSin
{
	float4 cpoint : POSITION;
	float3 norm : NORMAL;
	float4 TexCd: TEXCOORD0;
	uint vid : SV_VertexID ;
};

struct GSin
{
	float4 cpoint : POSITION;
	float3 norm : NORMAL;
	float4 TexCd: TEXCOORD0;
	uint iid : IID;
};

GSin VS(VSin input)
{
    GSin output;
	output = input;
	output.cpoint = mul(input.cpoint, transform);
	output.norm = mul(float4(input.norm.xyz,0), transform).xyz;
	output.TexCd = input.TexCd;
	output.iid = bLoad(iidb, 0,input.vid) + instanceOffset;
	
    return output;
}
[maxvertexcount(3)]
void GS(triangle GSin input[3], inout TriangleStream<GSin>GSOut)
{
	GSin v = (GSin)0;
	GSOut.RestartStrip();

	for(uint i=0;i<3;i++)
	{
		v=input[i];
		GSOut.Append(v);
	}
	GSOut.RestartStrip();
}

GeometryShader StreamOutGS = ConstructGSWithSO( CompileShader( gs_5_0, GS() ),
	"POSITION.xyz; NORMAL.xyz; TEXCOORD.xy; IID.x", NULL, NULL, NULL, -1);

technique11 Layout
{
	pass P0
	{
		
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		//SetGeometryShader( CompileShader( gs_5_0, GS() ) );
	    SetGeometryShader( StreamOutGS );

	}
}
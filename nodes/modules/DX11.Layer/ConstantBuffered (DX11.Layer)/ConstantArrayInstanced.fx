#include "..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> iidb;


float4x4 tVP : VIEWPROJECTION;

StructuredBuffer<float4x4>bTransform;
float4x4 tW : WORLD;

float4 cDefault <bool color=true;String uiname="Color Default";> = { 1.0f,1.0f,1.0f,1.0f };
StructuredBuffer<float4> vColBuffer;
iGeomIndex ColorIndexing <string linkclass="Instance,Primitive,Vertex";>;


Texture2DArray tex <string uiname="Texture";>;
SamplerState linearSampler 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
StructuredBuffer<float4x4>sbTexTransform;

struct vsInput
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;
	uint vid : SV_VertexID ;

};

struct psInput
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float4 Vcol : COL0;
	uint iid : IID;
};




psInput VS(vsInput input)
{
    psInput output;
	output.iid = iidb[input.vid];
    output.PosWVP  = mul(input.PosO,mul(bLoad(bTransform, tW, output.iid) ,tVP));
	//output.PosWVP  = mul(input.PosO,mul(bTransform[output.iid] ,tVP));
    //output.TexCd = input.TexCd;

	uint colID = ColorIndexing.Get(iidb[input.vid], floor(input.vid/3), input.vid );
	output.Vcol = bLoad(vColBuffer, cDefault, colID);
	


	output.TexCd = mul(input.TexCd, bLoad(sbTexTransform, tTex, output.iid));
	
    return output;
}


float4 PS(psInput input): SV_Target
{
    float4 col = input.Vcol;
    return col;
}

float4 PStex(psInput input): SV_Target
{
	uint texCount, dummy;	
	tex.GetDimensions(dummy,dummy,texCount);
    float4 col = tex.Sample(linearSampler,float3(input.TexCd.xy,input.iid % texCount)) * input.Vcol;
    return col;
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}

technique10 ConstantTextured
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PStex() ) );
	}
}




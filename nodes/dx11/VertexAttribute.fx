//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;
float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;

SamplerState g_samLinear <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
};

struct VS_IN
{
    float4 Pos  : POSITION;
    float4 Norm : NORMAL;
    float4 TexCd : TEXCOORD0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
	float4 PosW : TEXCOORD1;
	float4 NormW : NORMAL;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.Pos,mul(tW,tVP));
	Out.PosW  = mul(input.Pos, tW);
	Out.NormW  = mul(input.Norm, tW);
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}



float4 PSpos(vs2ps In): SV_Target
{
    float4 col = In.PosW;
	col.a=1;
	
    return col;
}

float4 PSnorm(vs2ps In): SV_Target
{
    float4 col = In.NormW * 0.5 + 0.5;
	col.a=1;
	
    return col;
}

float4 PSuv(vs2ps In): SV_Target
{
    float4 col = In.TexCd;
	col.a=1;
	
    return col;
}






technique10 Position
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSpos() ) );
	}
}

technique10 Normals
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSnorm() ) );
	}
}

technique10 UV
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSuv() ) );
	}
}





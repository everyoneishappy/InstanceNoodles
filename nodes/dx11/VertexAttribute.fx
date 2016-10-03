//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;
float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
bool nNormals <string uiname="Human Friendly Normals";>;
SamplerState g_samLinear <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tVI : VIEWINVERSE;
	float4x4 tWV : WORLDVIEW;
	float4x4 tV : VIEW;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float4x4 tWI:WORLDINVERSE;
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
	float4 Pos : TEXCOORD1;
	float4 Norm : NORMAL;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.Pos,mul(tW,tVP));
	Out.Pos  = mul(input.Pos, tW);
	Out.Norm  = mul(float4(input.Norm.xyz, 0), tWI);
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}


vs2ps viewVS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.Pos,mul(tW,tVP));
	Out.Pos  = mul(input.Pos, tWV);
	Out.Norm  = mul(float4(input.Norm.xyz, 0), mul(tWI, tV));
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}


float4 PSpos(vs2ps In): SV_Target
{
    float4 col = In.Pos;
	col.a=1;
	
    return col;
}

float4 PSnorm(vs2ps In): SV_Target
{
	float4 col = In.Norm;
	if (nNormals) col.rgb = col.rgb * 0.5 + 0.5; // human friendly
	col.a=1;
	
    return col;
}


float4 PSuv(vs2ps In): SV_Target
{
    float4 col = In.TexCd;
	col.a=1;
	
    return col;
}







technique10 WorldPosition
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSpos() ) );
	}
}

technique10 WorldNormals
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

technique10 ViewPosition
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, viewVS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSpos() ) );
	}
}

technique10 ViewNormals
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, viewVS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSnorm() ) );
	}
}



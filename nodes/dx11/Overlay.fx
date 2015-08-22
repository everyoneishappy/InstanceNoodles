//@author: Everyoneishappy
//@help: Depth Disabled Constant Shading
//@tags: 
//@credits: 
DepthStencilState DisableDepth
{

    DepthEnable = FALSE;
    DepthWriteMask = ZERO;
    DepthFunc = LESS_EQUAL;

    StencilEnable  = FALSE;

};

Texture2D texture2d <string uiname="Texture";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;

};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}




float4 PS(vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear,In.TexCd.xy);
	col *= cAmb;
	col.a *= Alpha;
    return col;
}





technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
		SetDepthStencilState( DisableDepth, 0 );
	
		//SetRasterizerState ();
	}
}





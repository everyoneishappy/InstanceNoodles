//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 



StructuredBuffer<float> tArea;
float factor;

 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
	float4x4 tColor <string uiname="Color Transform";>;
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
	float4 Color: TEXCOORD1;

};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
	Out.Color = 1;
    return Out;
}




float4 PS(vs2ps In, uint pid : SV_PrimitiveID): SV_Target
{
 	float4 col = factor * tArea[pid];
	col.a *= Alpha;
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





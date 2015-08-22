
 
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
	float4 Vcol : COLOR0;
};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
	float4 Vcol : COLOR0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.Pos,mul(tW,tVP));
	Out.Vcol  = input.Vcol;

    return Out;
}



float4 PSvcol(vs2ps In): SV_Target
{
    float4 col = In.Vcol;	
    return col;
}



technique10 vColor
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSvcol() ) );
	}
}





//@author: Everyoneishappy
//@help: Render WorldPos to uv layout
//@tags: UV
//@credits: 


float4 singleCol <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };


 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tP : PROJECTION;
	float4x4 tW : WORLD;

};



struct VS_IN
{
	float4 Pos : POSITION;
	float4 Norm : NORMAL;
	float4 UV : TEXCOORD0;

};


struct vs2ps
{
    float4 pPos: SV_POSITION;
	float4 Norm : NORMAL;
    float4 UV: TEXCOORD0;
	float4 PosW: TEXCOORD01;
};


vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
   
	    //transform position to UV
  //transform position
   // Out.position = mul(PosO, tWVP);
   	//
	Out.pPos = mul((input.UV-.5), tP);
	Out.pPos.y *= -1.0f;
	Out.pPos.z=0;
	
	Out.Norm = normalize(mul(input.Norm,tW));
	
    Out.UV = input.UV;
	Out.PosW  = mul(input.Pos,tW);

	
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
    float4 col = In.Norm;
	col.a=1;
	
    return col;
}

float4 PSuv(vs2ps In): SV_Target
{
    float4 col = In.UV;
	col.a=1;
	
    return col;
}

float4 PScol(vs2ps In): SV_Target
{
    return singleCol;
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

technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PScol() ) );
	}
}







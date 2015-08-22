
//Filtered buffer
StructuredBuffer<float3> sbPosition;

cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4 Color <bool color=true;>;
};


struct vsInput
{
	float4 pos : POSITION;
	uint ii : SV_InstanceID;
};

struct psInput
{
    float4 pos: SV_POSITION;		
};

psInput VS(vsInput input)
{
    psInput output;	

	float4 p = input.pos;
	//Get position from buffer
	p.xyz += sbPosition[input.ii];
    output.pos = mul(p,tVP);
    return output;
}

float4 PS_Tex(psInput input): SV_Target
{
    return Color;
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Tex() ) );
	}
}





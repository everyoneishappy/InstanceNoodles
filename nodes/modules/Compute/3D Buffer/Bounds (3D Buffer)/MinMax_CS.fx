
StructuredBuffer<float> InputBuffer;


struct vsInput
{
	uint vi :  SV_VertexID;
};

struct vs2ps
{
    float4 pos: SV_POSITION;
	float col: COL;
};



vs2ps VS(vsInput input)
{
    vs2ps output = (vs2ps)0;
    
	output.pos  = float4(0.0, 0.0 , 0.0 , 1.0f);
	output.col = InputBuffer[input.vi];
	//output.col = InputBuffer[0];
	//	output.col = 0;
	
	return output;
}



float4 PS(vs2ps input): SV_Target
{
    return input.col;
}



technique10 Process
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}
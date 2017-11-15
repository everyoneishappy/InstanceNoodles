RWStructuredBuffer<float> output : BACKBUFFER;

StructuredBuffer<float4x4> buffer;

[numthreads(1, 1, 1)]
void CS(uint3 i : SV_DispatchThreadID)
{ 
	uint count,dummy;	
	buffer.GetDimensions(count,dummy);	
	output[0] = count;
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








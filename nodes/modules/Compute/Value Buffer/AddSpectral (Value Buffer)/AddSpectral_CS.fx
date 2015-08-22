
RWStructuredBuffer<uint> output : BACKBUFFER;
float buffersize;
StructuredBuffer<float> inputBuffer;

[numthreads(64, 1, 1)]
void CS_Clear( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= buffersize) { return; }
	output[0] = 0;
}


[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	//if (dtid.x >= buffersize) { return; } 
	//  ^ not sure why need to take this out
	
	uint value = inputBuffer[dtid.x];
	InterlockedAdd(output[0], value);
}



technique11 Clear
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );
	}
}


technique11 PlusSpectral
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




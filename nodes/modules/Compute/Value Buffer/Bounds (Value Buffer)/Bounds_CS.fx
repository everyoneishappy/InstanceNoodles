
RWStructuredBuffer<int> output : BACKBUFFER;
uint buffersize;
StructuredBuffer<float> inputBuffer;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

#ifndef BIGNUMBER
#define BIGNUMBER 99999999
#endif

[numthreads(GROUPSIZE)]
void CS_Clear_Max( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= buffersize) { return; }
	output[0] = -BIGNUMBER;
}

[numthreads(GROUPSIZE)]
void CS_Clear_Min( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= buffersize) { return; }
	output[0] = BIGNUMBER;
}



[numthreads(GROUPSIZE)]
void CS_Max(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= buffersize) { return; } 	
	int value = inputBuffer[dtid.x] * BIGNUMBER;
	InterlockedMax(output[0], value);
}

[numthreads(GROUPSIZE)]
void CS_Min(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= buffersize) { return; } 
	int value = inputBuffer[dtid.x] * BIGNUMBER;
	InterlockedMin(output[0], value);
}





technique11 ClearMax
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear_Max() ) );
	}
}

technique11 ClearMin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear_Min() ) );
	}
}


technique11 Max
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Max() ) );
	}
}



technique11 Min
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Min() ) );
	}
}

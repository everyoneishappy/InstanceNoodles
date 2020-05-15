
RWStructuredBuffer<float> output : BACKBUFFER;
StructuredBuffer<int> inputBuffer;


#ifndef BIGNUMBER
#define BIGNUMBER 99999999.0
#endif

[numthreads(1, 1, 1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{ 
	output[dtid.x] = inputBuffer[0] / BIGNUMBER;
}



technique11 Result
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> InputBuffer, compareBuffer; 
float compareValue;

//Output buffer
RWStructuredBuffer<float> RWOutputBuffer : BACKBUFFER; 

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS_AND(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float compare = sbLoad(compareBuffer, compareValue, dtid.x);
	float value = sbLoad(InputBuffer, 0, dtid.x);
	RWOutputBuffer[dtid.x] = value && compare;
}

[numthreads(GROUPSIZE)]
void CS_OR(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float compare = sbLoad(compareBuffer, compareValue, dtid.x);
	float value = sbLoad(InputBuffer, 0, dtid.x);
	RWOutputBuffer[dtid.x] = value || compare;
}




technique11 AND
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_AND() ) );
	}
}

technique11 OR
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_OR() ) );
	}
}


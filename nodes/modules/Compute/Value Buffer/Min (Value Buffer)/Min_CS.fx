#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> ValueBuffer;
float minDefault;
StructuredBuffer<float> minBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;
uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]

void CS_Min(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = min(ValueBuffer[dtid.x % sbSize(ValueBuffer)], sbLoad(minBuffer, minDefault, dtid.x));
}



technique11 Min
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Min() ) );
	}
}


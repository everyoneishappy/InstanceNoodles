#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> ValueBuffer;
float maxDefault;
StructuredBuffer<float> maxBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif
[numthreads(GROUPSIZE)]
void CS_Max(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = max(ValueBuffer[dtid.x % sbSize(ValueBuffer)], sbLoad(maxBuffer, maxDefault, dtid.x));
}



technique11 Max
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Max() ) );
	}
}


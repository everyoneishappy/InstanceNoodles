#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> ValueBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Abs(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = abs(ValueBuffer[dtid.x % sbSize(ValueBuffer)]);
}



technique11 Abs
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Abs() ) );
	}
}


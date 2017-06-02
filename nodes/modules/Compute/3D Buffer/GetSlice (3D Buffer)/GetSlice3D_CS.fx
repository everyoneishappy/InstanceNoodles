#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> Output : BACKBUFFER;
StructuredBuffer<float3> ValueBuffer; //// <- change these two lines for datatype

StructuredBuffer<float> indexBuffer;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float index = sbLoad (indexBuffer, 0, dtid.x);
	Output[dtid.x] = ValueBuffer[index % sbSize(ValueBuffer)];
}



technique11 GetSlice
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float3> spreadBuffer;
RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;
int cols,rows = 8;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_SD(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	uint count = sbSize(spreadBuffer);
	uint i = dtid.x;
	uint newIndex = (i%rows)*cols+i/rows;
	
	RWValueBuffer[dtid.x] = spreadBuffer[newIndex];
	
}




technique11 SwapDim
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SD() ) );
	}
}




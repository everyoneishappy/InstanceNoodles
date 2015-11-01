#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float3> spreadBuffer;
RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;
int cols,rows = 8;

[numthreads(64,1,1)]
void CS_SD(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	uint count = bSize(spreadBuffer);
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




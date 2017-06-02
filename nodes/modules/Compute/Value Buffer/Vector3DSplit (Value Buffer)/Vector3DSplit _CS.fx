#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float3> bVector;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_VectorSplit_X(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }	
	RWValueBuffer[i.x] = bVector[i.x % sbSize(bVector)].x;
}

[numthreads(GROUPSIZE)]
void CS_VectorSplit_Y(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }	
	RWValueBuffer[i.x] = bVector[i.x % sbSize(bVector)].y;
	
}


[numthreads(GROUPSIZE)]
void CS_VectorSplit_Z(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }	
	RWValueBuffer[i.x] = bVector[i.x % sbSize(bVector)].z;
	
}



technique11 VectorSplitX
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorSplit_X() ) );
	}
}

technique11 VectorSplitY
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorSplit_Y() ) );
	}
}


technique11 VectorSplitZ
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorSplit_Z() ) );
	}
}



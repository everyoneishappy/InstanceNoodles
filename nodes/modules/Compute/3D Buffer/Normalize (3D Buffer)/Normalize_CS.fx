#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> output : BACKBUFFER;
StructuredBuffer<float3> inputBuffer;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Norm ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	float3 v = inputBuffer[dtid.x % sbSize(inputBuffer)];
	output[dtid.x] = normalize(v);
}


technique11 Normalize
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Norm() ) );
	}
}







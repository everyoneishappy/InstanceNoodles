#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> Output : BACKBUFFER;
StructuredBuffer<float3> spreadBuffer; 
StructuredBuffer<float3> setBuffer; 
float3 setDefault;
StructuredBuffer<float> indexBuffer;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Pass(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	Output[dtid.x] = spreadBuffer[dtid.x % sbSize(spreadBuffer)];
}

[numthreads(GROUPSIZE)]
void CS_Set(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	uint index = sbLoad (indexBuffer, 0, dtid.x);
	Output[index] = sbLoad(setBuffer, setDefault, dtid.x);
}



technique11 SetSlice
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Set() ) );
	}
}

technique11 PassThrough
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Pass() ) );
	}
}

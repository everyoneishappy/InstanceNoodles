#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float3> vectorBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Length(uint3 i : SV_DispatchThreadID)
{
	if (i.x > threadCount) { return; }
	float Result = length(vectorBuffer [i.x % sbSize(vectorBuffer)]);
	RWValueBuffer[i.x] = Result;	
}


technique11 Length
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Length() ) );
	}
}


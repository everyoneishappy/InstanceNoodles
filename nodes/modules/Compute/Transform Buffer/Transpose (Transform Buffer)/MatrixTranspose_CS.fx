#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
float4x4 dt;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	output[dtid.x] = transpose(sbLoad(bTransform, dt, dtid.x));
}



technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








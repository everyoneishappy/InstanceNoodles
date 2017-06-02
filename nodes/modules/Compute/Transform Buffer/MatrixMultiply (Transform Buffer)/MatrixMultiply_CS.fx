#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransformA;
StructuredBuffer<float4x4> bTransformB;
float4x4 dtA, dtB;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSmul( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	output[dtid.x] = mul(sbLoad(bTransformA, dtA, dtid.x), sbLoad(bTransformB, dtB, dtid.x));
}



technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSmul() ) );
	}
}








#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
float3 dRotate = 0;
StructuredBuffer<float3> bRotate;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float4x4 mat = sbLoad(bTransform, identity4x4(), dtid.x);
	float3 rotate = sbLoad(bRotate, dRotate, dtid.x);

	output[dtid.x] = mul (rot4x4(rotate), mat);
	
	
	
}



technique11 Rotate
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








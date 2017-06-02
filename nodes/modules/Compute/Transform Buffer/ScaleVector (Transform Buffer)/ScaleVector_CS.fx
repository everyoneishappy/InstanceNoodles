#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif
RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
float3 scaleDefualt = 1;
StructuredBuffer<float3> bScale;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
		
	float4x4 tMat = sbLoad(bTransform, identity4x4(), dtid.x);
	float3 scale = sbLoad(bScale, scaleDefualt, dtid.x); 
	output[dtid.x] = mul(scaleM(scale, identity4x4()), tMat);
	
	
	
}



technique11 Scale
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








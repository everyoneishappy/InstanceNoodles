#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif
RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float> xb,yb,zb;
float x,y,z = 0;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; } 

	float4x4 tMat = sbLoad(bTransform, identity4x4(), dtid.x);
	float3 xyz;
	xyz.x = sbLoad(xb,x,dtid.x);
	xyz.y = sbLoad(yb,y,dtid.x);
	xyz.z = sbLoad(zb,z,dtid.x);
	
	output[dtid.x] = translateM(xyz, tMat);
}



technique11 FeedbackTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float3> bDir;
float3 dirValue=0;
float3 upvector = float3(0,1,0);


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSlookat( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; } 

	float4x4 tMat = sbLoad(bTransform, identity4x4(), dtid.x);
	float3 dir = normalize(sbLoad(bDir, dirValue, dtid.x));
	output[dtid.x] = mul(lookat4x4(dir,upvector), tMat);
}



technique11 LookAtTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSlookat() ) );
	}
}








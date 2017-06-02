#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif

StructuredBuffer<float4x4> transformBuffer;

RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_VectorJoin(uint3 i : SV_DispatchThreadID)
{

	if (i.x >= threadCount) { return; } 	
	
	float4x4 mat = sbLoad(transformBuffer, identity4x4(), i.x);
	float3 pos = float3(mat._41, mat._42, mat._43);
	RWValueBuffer[i.x] = pos;
	
}




technique11 GetPos
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


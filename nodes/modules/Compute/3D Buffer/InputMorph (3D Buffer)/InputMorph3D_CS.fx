#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> output : BACKBUFFER;

float lerpValue = 0;
StructuredBuffer<float> lerpBuffer;

float3 dv1, dv2 = 0;
StructuredBuffer<float3> bv1, bv2;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSlerp( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float3 v1 = sbLoad(bv1, dv1, dtid.x);
	float3 v2 = sbLoad(bv2, dv2, dtid.x);
	float l = sbLoad(lerpBuffer, lerpValue, dtid.x);

	output[dtid.x] = lerp(v1, v2, l);
}



technique11 Lerp
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSlerp() ) );
	}
}








#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


RWStructuredBuffer<float4x4> output : BACKBUFFER;

float lerpDefault = 0;
StructuredBuffer<float> lerpBuffer;
StructuredBuffer<float4x4> transform1B;
StructuredBuffer<float4x4> transform2B;

float4x4 transform1Default, transform2Default;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSlerp( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	

	float4x4 t1 = sbLoad(transform1B, transform1Default, dtid.x);
	float4x4 t2 = sbLoad(transform2B, transform2Default, dtid.x);
	float l = sbLoad(lerpBuffer, lerpDefault, dtid.x);

	output[dtid.x] = lerp(t1, t2, l);
}



technique11 Lerp
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSlerp() ) );
	}
}








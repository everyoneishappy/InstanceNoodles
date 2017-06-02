#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float4x4> bFeedbackTransform; 
// set default value for matrices if buffers are empty
float4x4 dTransform, dFbt;

int iterations = 3;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	uint tCount = sbSize(bTransform);
	uint ftCount = sbSize(bFeedbackTransform);


	uint tID = (dtid.x / (iterations+1)) % tCount;
	float4x4 transform = sbLoad(bTransform, dTransform, tID);
	

	uint ftID = (dtid.x - tID) % ftCount;
	float4x4 fbt = sbLoad(bFeedbackTransform, dFbt, ftID);

	if(dtid.x % (iterations +1)==0) output[dtid.x] = transform;
	else output[dtid.x] = mul(fbt,output[dtid.x-1]);
}



technique11 FeedbackTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








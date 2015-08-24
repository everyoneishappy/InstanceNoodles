#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float4x4> bFeedbackTransform; 
// set default value for matrices if buffers are empty
float4x4 dTransform, dFbt;

int iterations = 3;

[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	uint tCount = bSize(bTransform);
	uint ftCount = bSize(bFeedbackTransform);


	uint tID = (dtid.x / (iterations+1)) % tCount;
	float4x4 transform = bLoad(bTransform, dTransform, tID);
	

	uint ftID = (dtid.x - tID) % ftCount;
	float4x4 fbt = bLoad(bFeedbackTransform, dFbt, ftID);

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








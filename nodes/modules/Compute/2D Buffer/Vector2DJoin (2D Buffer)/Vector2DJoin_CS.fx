#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> xb,yb;
float x,y = 0;


RWStructuredBuffer<float2> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float2 xy = float2(bLoad(xb,x,dtid.x), bLoad(yb,y,dtid.x));
	RWValueBuffer[dtid.x] = xy;
	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


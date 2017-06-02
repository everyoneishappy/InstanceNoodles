#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> xb,yb;
float x,y = 0;

RWStructuredBuffer<float2> RWValueBuffer : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float2 xy = float2(sbLoad(xb,x,dtid.x), sbLoad(yb,y,dtid.x));
	RWValueBuffer[dtid.x] = xy;
	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


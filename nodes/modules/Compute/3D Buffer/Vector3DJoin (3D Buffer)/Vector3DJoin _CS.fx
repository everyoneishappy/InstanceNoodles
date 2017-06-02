#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> xb,yb,zb;
float x,y,z = 0;


RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 xyz;
	xyz.x = sbLoad(xb,x,dtid.x);
	xyz.y = sbLoad(yb,y,dtid.x);
	xyz.z = sbLoad(zb,z,dtid.x);

	
	RWValueBuffer[dtid.x] = xyz;
	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


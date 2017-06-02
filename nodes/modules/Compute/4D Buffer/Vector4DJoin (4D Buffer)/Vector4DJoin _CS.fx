#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> xb,yb,zb,wb;
float x,y,z,w = 0;


RWStructuredBuffer<float4> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > threadCount) { return; }
	
	float4 Vec;
	Vec.x = sbLoad(xb,x,dtid.x);
	Vec.y = sbLoad(yb,y,dtid.x);
	Vec.z = sbLoad(zb,z,dtid.x);
	Vec.w = sbLoad(wb,w,dtid.x);
	
	RWValueBuffer[dtid.x] = Vec;	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


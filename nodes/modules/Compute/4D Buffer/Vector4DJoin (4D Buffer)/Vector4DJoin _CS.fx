#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> xb,yb,zb,wb;
float x,y,z,w = 0;


RWStructuredBuffer<float4> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > threadCount) { return; }
	
	float4 Vec;
	Vec.x = bLoad(xb,x,dtid.x);
	Vec.y = bLoad(yb,y,dtid.x);
	Vec.z = bLoad(zb,z,dtid.x);
	Vec.w = bLoad(wb,w,dtid.x);
	
	RWValueBuffer[dtid.x] = Vec;	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


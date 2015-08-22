#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> xb,yb,zb;
float x,y,z = 0;


RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_VectorJoin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 xyz;
	xyz.x = bLoad(xb,x,dtid.x);
	xyz.y = bLoad(yb,y,dtid.x);
	xyz.z = bLoad(zb,z,dtid.x);

	
	RWValueBuffer[dtid.x] = xyz;
	
}




technique11 VectorJoin
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransformA;
StructuredBuffer<float4x4> bTransformB;
float4x4 dtA, dtB;


[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	output[dtid.x] = mul(bLoad(bTransformA, dtA, dtid.x), bLoad(bTransformB, dtB, dtid.x));
}



technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








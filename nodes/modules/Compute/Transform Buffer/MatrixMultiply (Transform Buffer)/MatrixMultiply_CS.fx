#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float4x4> bTransform2;


[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	// set default value for buffer if empty
	float4x4 dt ={ 1, 0, 0,  0, 
 				0, 1, 0,  0, 
 				0, 0, 1,  0, 
  				0, 0, 0,  1 };

	output[dtid.x] = mul(bLoad(bTransform, dt, dtid.x), bLoad(bTransform2, dt, dtid.x));
}



technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








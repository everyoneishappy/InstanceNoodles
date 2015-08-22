#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

float lerpValue = 0;
StructuredBuffer<float> lerpBuffer;
StructuredBuffer<float4x4> transform;
StructuredBuffer<float4x4> transform2;




[numthreads(64, 1, 1)]
void CSlerp( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	// set default value for buffer if empty
	float4x4 defaultT ={ 1, 0, 0,  0, 
 				0, 1, 0,  0, 
 				0, 0, 1,  0, 
  				0, 0, 0,  1 };
	float4x4 t1 = bLoad(transform, defaultT, dtid.x);
	float4x4 t2 = bLoad(transform2, defaultT, dtid.x);
	float l = bLoad(lerpBuffer, lerpValue, dtid.x);

	output[dtid.x] = lerp(t1, t2, l);
}



technique11 Lerp
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSlerp() ) );
	}
}








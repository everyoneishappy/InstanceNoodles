#include "..\..\..\Common\InstanceNoodles.fxh"
#include "iqNoise.fxh"
float3 fbmstr =.01;
float3 fbmfreq=1;
float3 offset;

StructuredBuffer<float3> XYZbuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS_Noise( uint3 dTid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float3 v = XYZbuffer[dTid.x];
		
	Output[dTid.x] = iqFbm3d(v*fbmfreq+offset)*fbmstr.x;
		
	
}



//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 Noise
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Noise() ) );
	}
}

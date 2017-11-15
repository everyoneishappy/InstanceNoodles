int threadCount;
#include "noiseSimplex.fxh"

float4 freq=1;
float3 offset;
float strength = 1;
float time;

StructuredBuffer<float3> XYZbuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS_Noise( uint3 dtid : SV_DispatchThreadID )
{

	if (dtid.x >= threadCount) { return; }
	
	float3 v = XYZbuffer[dtid.x];
	float ns = snoise(float4(v,0) * freq + float4(offset, time)) * strength;
	Output[dtid.x] = ns;
		
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

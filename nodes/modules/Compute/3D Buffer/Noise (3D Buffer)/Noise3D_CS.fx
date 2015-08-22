
#include "..\..\..\Common\InstanceNoodles.fxh"

#include "iqNoise.fxh"
float3 fbmstr =.01;
float3 fbmfreq=1;
float3 offset;

StructuredBuffer<float3> XYZbuffer;
RWStructuredBuffer<float3> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS_NoisePos( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; }

	float3 v = bLoad(XYZbuffer, 0, DTid.x);
	
	float3 result;
		
	//Add velocity noise
	result.x = iqFbm3d(v*fbmfreq+offset)*fbmstr.x;
	result.y = iqFbm3d(v*fbmfreq*float3(.097,.09,.098)+offset+float3(97.34,23.36,2))*fbmstr.y;
	result.z = iqFbm3d(v*fbmfreq*float3(1.09,1.02,1.005)+offset+float3(17.34,28.96,300.7))*fbmstr.z;
		
	Output[DTid.x] = v+result;
}

[numthreads(64, 1, 1)]
void CS_NoiseVec( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; }

	float3 v = bLoad(XYZbuffer, 0, DTid.x);
	
	float3 result;
		
	//Add velocity noise
	result.x = iqFbm3d(v*fbmfreq+offset)*fbmstr.x;
	result.y = iqFbm3d(v*fbmfreq*float3(.097,.09,.098)+offset+float3(97.34,23.36,2))*fbmstr.y;
	result.z = iqFbm3d(v*fbmfreq*float3(1.09,1.02,1.005)+offset+float3(17.34,28.96,300.7))*fbmstr.z;
		
	Output[DTid.x] = result;
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 NoisePos
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_NoisePos() ) );
	}
}

technique11 NoiseVector
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_NoiseVec() ) );
	}
}
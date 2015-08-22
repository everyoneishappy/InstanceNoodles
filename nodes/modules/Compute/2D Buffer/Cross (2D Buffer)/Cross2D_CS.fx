#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float2> Output: BACKBUFFER;

StructuredBuffer<float> xB;
StructuredBuffer<float> yB;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSConstantForce( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	// get buffer count
	uint xBcount = bSize(xB);

	
	uint colI = dtid.x % xBcount;
	uint rowI = floor(dtid.x / xBcount)% xBcount;
	
	Output[dtid.x].x = xB[colI];
	Output[dtid.x].y = yB[rowI];		
	
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

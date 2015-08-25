#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> Output: BACKBUFFER;
StructuredBuffer<float> xB, yB, zB;
int tc;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSCross3D( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	
	uint xBcount = bSize(xB);
	uint yBcount = bSize(yB);	
	uint zBcount = bSize(zB);	
	
	uint colI = dtid.x % xBcount;
	uint rowI = dtid.x / xBcount % xBcount;
	uint pageI = dtid.x / (xBcount*yBcount) % zBcount;

	Output[dtid.x] = float3( xB[colI], yB[rowI], zB[pageI]) ;


		

	
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 Cross
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSCross3D() ) );
	}
}

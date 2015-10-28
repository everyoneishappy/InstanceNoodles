#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> Output: BACKBUFFER;
StructuredBuffer<float> xB, yB, zB;
float defaultX, defaultY, defaultZ;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSCross3D( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	
	uint xBcount = max(bSize(xB), 1);
	uint yBcount = max(bSize(yB), 1);	
	uint zBcount = max(bSize(zB), 1);	
	
	uint colI = dtid.x % xBcount;
	uint rowI = dtid.x / xBcount % xBcount;
	uint pageI = dtid.x / (xBcount*yBcount) % zBcount;

	Output[dtid.x] = float3( bLoad(xB, defaultX, colI), bLoad(yB, defaultY, rowI), bLoad( zB, defaultZ, pageI)) ;


		

	
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

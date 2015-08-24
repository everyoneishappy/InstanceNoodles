#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> Output: BACKBUFFER;

StructuredBuffer<float> xB;
StructuredBuffer<float> yB;
StructuredBuffer<float> zB;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSCross3D( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	// get buffer counts
	//uint xBcount, yBcount, zBcount, dummy;	
	//xB.GetDimensions(xBcount,dummy), yB.GetDimensions(yBcount,dummy), zB.GetDimensions(zBcount,dummy);
	float xBcount = bSize(xB);
	float yBcount = bSize(yB);	
	float zBcount = bSize(zB);	
	float colI = dtid.x % xBcount;
	float rowI = floor(dtid.x / xBcount)% xBcount;
	float pageI = floor(dtid.x / (xBcount*yBcount)) % zBcount;
	
	//uint rowI = dtid.x / xBcount % xBcount;
	//uint pageI = dtid.x / (xBcount*yBcount) % zBcount;

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

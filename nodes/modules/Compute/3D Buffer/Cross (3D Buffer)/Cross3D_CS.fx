//#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> Output: BACKBUFFER;
StructuredBuffer<float> xB, yB, zB;
int threadCount;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSCross3D( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	
	// get buffer counts
	uint xBcount, yBcount, zBcount, dummy;	
	xB.GetDimensions(xBcount,dummy), yB.GetDimensions(yBcount,dummy), zB.GetDimensions(zBcount,dummy);
	//uint xBcount = bSize(xB);
	//float yBcount = bSize(yB);	
	//float zBcount = bSize(zB);	
	
	uint colI = dtid.x % xBcount;
	uint rowI = floor(dtid.x / xBcount) % xBcount;
	uint pageI = floor(dtid.x / (xBcount*yBcount)) % zBcount;

	Output[dtid.x] = float3( xB[colI], yB[rowI], zB[pageI]) ;
	//Output[dtid.x] = float3( colI, rowI, pageI) ;
	//Output[dtid.x] = float3( xBcount, yBcount,  zBcount) ;
	
		

	
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

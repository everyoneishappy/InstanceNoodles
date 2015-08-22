

RWStructuredBuffer<float3> Output: BACKBUFFER;

StructuredBuffer<float> xB;
StructuredBuffer<float> yB;
StructuredBuffer<float> zB;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSCross3D( uint3 DTid : SV_DispatchThreadID )
{

	// get buffer counts
	uint xBcount, yBcount, zBcount, dummy;	
	xB.GetDimensions(xBcount,dummy), yB.GetDimensions(yBcount,dummy), zB.GetDimensions(zBcount,dummy);
	
	uint colI = DTid.x % xBcount;
	uint rowI = floor(DTid.x / xBcount)% xBcount;
	uint pageI = floor(DTid.x / (xBcount*yBcount)) % zBcount;
	//rowI =DTid.x;
	
	
	Output[DTid.x] = float3( xB[colI], yB[rowI], zB[pageI]) ;
	
		

	
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSCross3D() ) );
	}
}

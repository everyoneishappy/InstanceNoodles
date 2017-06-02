#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif




RWStructuredBuffer<uint> output : BACKBUFFER;
StructuredBuffer<float> bGridIndex;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS_Clear( uint3 dtid : SV_DispatchThreadID)
{ 
	output[dtid.x] = 0;
}


[numthreads(GROUPSIZE)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	 
	// get buffer count
	uint iCount,dummy;	
	bGridIndex.GetDimensions(iCount,dummy);
	
	// set default value for buffer if empty
	uint gridIndex = 0;
	if(iCount>0) gridIndex = bGridIndex[dtid.x % iCount];
	


	InterlockedAdd(output[gridIndex], 1);
}



technique11 Clear
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );
	}
}


technique11 GetIndices
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




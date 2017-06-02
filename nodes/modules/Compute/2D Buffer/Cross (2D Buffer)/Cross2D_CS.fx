#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float2> Output: BACKBUFFER;

StructuredBuffer<float> xB;
StructuredBuffer<float> yB;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSConstantForce( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	// get buffer count
	uint xBcount = sbSize(xB);

	
	uint colI = dtid.x % xBcount;
	uint rowI = floor(dtid.x / xBcount)% xBcount;
	
	Output[dtid.x].x = xB[colI];
	Output[dtid.x].y = yB[rowI];		
	
}



technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


RWStructuredBuffer<float3> Output: BACKBUFFER;
StructuredBuffer<float> xB, yB, zB;
float defaultX, defaultY, defaultZ;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSCross3D( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	
	uint xBcount = max(sbSize(xB), 1);
	uint yBcount = max(sbSize(yB), 1);	
	uint zBcount = max(sbSize(zB), 1);	
	
	uint colI = dtid.x % xBcount;
	uint rowI = (dtid.x / xBcount) % yBcount;
	uint pageI = dtid.x / (xBcount*yBcount) % zBcount;

	Output[dtid.x] = float3( sbLoad(xB, defaultX, colI), sbLoad(yB, defaultY, rowI), sbLoad( zB, defaultZ, pageI)) ;


		

	
}



technique11 Cross
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSCross3D() ) );
	}
}

#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


uint threadCount;
RWStructuredBuffer<float2> RWValueBuffer : BACKBUFFER;
StructuredBuffer<float> scB;

float2 binAndOffset(StructuredBuffer<float> binsize, float id)
{
	
	uint offset = 0;
	uint count = sbSize(binsize);
	
	for (uint i=0; i < count+1; i++)
	{
		if (offset+binsize[i] > id) return float2(i,id - offset);
		else offset += binsize[i];
	}
	return 0;
}

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = binAndOffset(scB, dtid.x);
}



technique11 I_64
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



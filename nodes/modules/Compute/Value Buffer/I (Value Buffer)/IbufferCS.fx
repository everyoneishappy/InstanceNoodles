#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;
float fromDefault, phaseDefault;
StructuredBuffer<float> fromBuffer,phaseBuffer;


StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y;

	
	float from = sbLoad(fromBuffer, fromDefault, bin);
	float phase = abs(sbLoad(phaseBuffer, phaseDefault, bin));
	
	float result = (id + floor(phase * binsize)) % binsize;
	result += from;
	RWValueBuffer[dtid.x] = floor(result);
}




technique11 I_64
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




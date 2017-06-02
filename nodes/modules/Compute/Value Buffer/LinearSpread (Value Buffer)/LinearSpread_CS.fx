#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


float widthDefault, offsetDefault, phaseDefault;
StructuredBuffer<float> widthBuffer, offsetBuffer, phaseBuffer, binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;
uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_LinearSpread (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y;
	
	float width = sbLoad(widthBuffer, widthDefault, bin);
	float offset = sbLoad(offsetBuffer, offsetDefault, bin);
	float phase = sbLoad(phaseBuffer, phaseDefault, bin);
	
	id = (id + (phase * binsize )) % binsize;
	
	float result = (width/binsize) * id - (width/2) + offset;
	RWValueBuffer[dtid.x] = result;
	
}

technique11 LinearSpread
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_LinearSpread () ) );
	}
}




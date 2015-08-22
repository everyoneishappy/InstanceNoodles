#include "..\..\..\Common\InstanceNoodles.fxh"


RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;
float fromDefault, phaseDefault;
StructuredBuffer<float> fromBuffer,phaseBuffer;


StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y;

	
	float from = bLoad(fromBuffer, fromDefault, id);
	float phase = abs(bLoad(phaseBuffer, phaseDefault, id));
	
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




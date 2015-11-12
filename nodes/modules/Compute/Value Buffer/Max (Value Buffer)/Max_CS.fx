#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> ValueBuffer;
float maxDefault;
StructuredBuffer<float> maxBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;



[numthreads(64,1,1)]
void CS_Max(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = max(ValueBuffer[dtid.x % bSize(ValueBuffer)], bLoad(maxBuffer, maxDefault, dtid.x));
}



technique11 Max
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Max() ) );
	}
}


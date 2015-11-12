#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> ValueBuffer;
float minDefault;
StructuredBuffer<float> minBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;



[numthreads(64,1,1)]
void CS_Min(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = min(ValueBuffer[dtid.x % bSize(ValueBuffer)], bLoad(minBuffer, minDefault, dtid.x));
}



technique11 Min
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Min() ) );
	}
}


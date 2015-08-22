#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> ValueBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;



[numthreads(64,1,1)]
void CS_Abs(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	RWValueBuffer[dtid.x] = abs(ValueBuffer[dtid.x % bSize(ValueBuffer)]);
}



technique11 Abs
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Abs() ) );
	}
}


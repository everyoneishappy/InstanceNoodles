#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float4> valueBuffer;
bool setDefault;
StructuredBuffer<float> setBuffer;
RWStructuredBuffer<float4> RWValueBuffer : BACKBUFFER;



[numthreads(64,1,1)]
void CS_SampleAndHold(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	bool set = bLoad(setBuffer, setDefault, dtid.x);
	if (set) RWValueBuffer[dtid.x] = valueBuffer[dtid.x % bSize(valueBuffer)];
}



technique11 SampleAndHold
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SampleAndHold() ) );
	}
}


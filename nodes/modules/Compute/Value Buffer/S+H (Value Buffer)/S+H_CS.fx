#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> valueBuffer;
bool setDefault;
StructuredBuffer<float> setBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;



uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif
[numthreads(GROUPSIZE)]
void CS_SampleAndHold(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	bool set = sbLoad(setBuffer, setDefault, dtid.x);
	if (set) RWValueBuffer[dtid.x] = valueBuffer[dtid.x % sbSize(valueBuffer)];
}



technique11 SampleAndHold
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SampleAndHold() ) );
	}
}


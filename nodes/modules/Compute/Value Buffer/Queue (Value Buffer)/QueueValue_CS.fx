#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

float frameCount;

StructuredBuffer<float> valueBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif
[numthreads(GROUPSIZE)]
void CS_SD(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	uint vCount = sbSize(valueBuffer);
	
	//float colIndex = dtid.x % vCount;
	float rowIndex = floor(dtid.x / vCount);
	
	if(rowIndex == 0) RWValueBuffer[dtid.x]= valueBuffer[dtid.x];
	else RWValueBuffer[dtid.x] = RWValueBuffer[dtid.x-vCount];
	

	
}




technique11 Queue
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SD() ) );
	}
}







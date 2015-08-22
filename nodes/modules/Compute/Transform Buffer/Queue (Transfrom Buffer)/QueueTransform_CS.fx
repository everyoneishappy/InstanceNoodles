#include "..\..\..\Common\InstanceNoodles.fxh"

float frameCount;

StructuredBuffer<float4x4> valueBuffer;
RWStructuredBuffer<float4x4> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_SD(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; } // discard threads that will overflow total thread count
	
	uint vCount,dummy;	
	valueBuffer.GetDimensions(vCount,dummy);
	
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







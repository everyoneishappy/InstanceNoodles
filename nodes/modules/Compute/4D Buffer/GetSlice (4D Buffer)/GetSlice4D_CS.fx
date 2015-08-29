#include "..\..\..\Common\InstanceNoodles.fxh"


RWStructuredBuffer<float4> Output : BACKBUFFER;
StructuredBuffer<float4> ValueBuffer; //// <- change these two lines for datatype

StructuredBuffer<float> indexBuffer;

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float index = bLoad (indexBuffer, 0, dtid.x);
	Output[dtid.x] = ValueBuffer[index % bSize(ValueBuffer)];
}



technique11 GetSlice
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



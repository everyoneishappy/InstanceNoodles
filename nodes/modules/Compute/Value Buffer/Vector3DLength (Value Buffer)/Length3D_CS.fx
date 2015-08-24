#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float3> vectorBuffer;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_Length(uint3 i : SV_DispatchThreadID)
{
	if (i.x > threadCount) { return; }
	float Result = length(vectorBuffer [i.x % bSize(vectorBuffer)]);
	RWValueBuffer[i.x] = Result;	
}


technique11 Length
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Length() ) );
	}
}


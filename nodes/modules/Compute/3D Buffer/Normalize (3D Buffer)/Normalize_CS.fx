#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> output : BACKBUFFER;
StructuredBuffer<float3> inputBuffer;

[numthreads(64, 1, 1)]
void CS_Norm ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	float3 v = inputBuffer[dtid.x % bSize(inputBuffer)];
	output[dtid.x] = normalize(v);
}


technique11 Normalize
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Norm() ) );
	}
}







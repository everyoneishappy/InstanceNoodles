#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> InputBuffer, compareBuffer; 
float compareValue;

//Output buffer
RWStructuredBuffer<float> RWOutputBuffer : BACKBUFFER; 

[numthreads(64,1,1)]
void CS_AND(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float compare = bLoad(compareBuffer, compareValue, dtid.x);
	float value = bLoad(InputBuffer, 0, dtid.x);
	RWOutputBuffer[dtid.x] = value && compare;
}

[numthreads(64,1,1)]
void CS_OR(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float compare = bLoad(compareBuffer, compareValue, dtid.x);
	float value = bLoad(InputBuffer, 0, dtid.x);
	RWOutputBuffer[dtid.x] = value || compare;
}




technique11 AND
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_AND() ) );
	}
}

technique11 OR
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_OR() ) );
	}
}


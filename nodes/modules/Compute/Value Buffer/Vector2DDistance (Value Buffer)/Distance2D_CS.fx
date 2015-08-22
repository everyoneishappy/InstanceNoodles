#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float2> vector1Buffer, vector2Buffer;
float2 vector1Value, vector2Value = float2(0,1);
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

[numthreads(64,1,1)]
void CS_Distance (uint3 i : SV_DispatchThreadID)
{
	if (i.x > threadCount) { return; }
	
	float Result = distance(bLoad(vector1Buffer, vector1Value, i.x), bLoad(vector2Buffer, vector2Value, i.x));
	
	RWValueBuffer[i.x] = Result;	
}





technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Distance() ) );
	}
}


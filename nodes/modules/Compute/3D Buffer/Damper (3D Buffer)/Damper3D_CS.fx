#include "..\..\..\Common\InstanceNoodles.fxh"

bool resetDefualt;
float dampingDefualt = 0.8;
StructuredBuffer<float> dampingBuffer, resetBuffer;




StructuredBuffer<float3> inputBuffer;

RWStructuredBuffer<float3> Output : BACKBUFFER;


[numthreads(64, 1, 1)]
void CS_Damper( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x > threadCount) { return; }
	
	bool reset = bLoad(resetBuffer, resetDefualt, i.x);
	
	if (reset) 
	{ 
		Output[i.x] = inputBuffer[i.x];
		return;
	}
	
	
	float damp = saturate(bLoad(dampingBuffer, dampingDefualt, i.x));
	Output[i.x] =  lerp (inputBuffer[i.x], Output[i.x], damp);
}




technique11 Damper3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Damper() ) );
	}
}







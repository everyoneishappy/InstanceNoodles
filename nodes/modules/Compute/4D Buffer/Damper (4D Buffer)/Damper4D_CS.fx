#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


bool resetDefualt;
float dampingDefualt = 0.8;
StructuredBuffer<float> dampingBuffer, resetBuffer;




StructuredBuffer<float4> inputBuffer;

RWStructuredBuffer<float4> Output : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Damper( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x > threadCount) { return; }
	
	bool reset = sbLoad(resetBuffer, resetDefualt, i.x);
	
	if (reset) 
	{ 
		Output[i.x] = inputBuffer[i.x];
		return;
	}
	
	
	float damp = saturate(sbLoad(dampingBuffer, dampingDefualt, i.x));
	Output[i.x] =  lerp (inputBuffer[i.x], Output[i.x], damp);
}




technique11 Damper3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Damper() ) );
	}
}







#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


bool resetDefualt;
StructuredBuffer<float> resetBuffer;

float attackDefualt = 0.2;
StructuredBuffer<float> attackBuffer;

float decayDefualt = 0.9;
StructuredBuffer<float> decayBuffer;

StructuredBuffer<float> inputBuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;

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
	
	
	float attack = saturate(sbLoad(attackBuffer, attackDefualt, i.x));
	float decay = saturate(sbLoad(decayBuffer, decayDefualt, i.x));
	
	float velDir = sign(inputBuffer[i.x] - Output[i.x]);  //direction of movment(target pos - old pos)
	
	float damp = max(velDir, 0) * attack + min(velDir, 0) * -decay;
	
	Output[i.x] =  lerp (inputBuffer[i.x], Output[i.x], damp);
}




technique11 Decay
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Damper() ) );
	}
}







#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> ValueBuffer, GammaBuffer;
float GammaValue = 1;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

float pows(float a, float b) {return pow(abs(a),b)*sign(a);}

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS_Gamma(uint3 dtid : SV_DispatchThreadID)
{
		if (dtid.x >= threadCount) { return; }
	
	float gamma = sbLoad(GammaBuffer, GammaValue, dtid.x);
	
	RWValueBuffer[dtid.x] = pows(ValueBuffer[dtid.x],gamma);
}



technique11 Gamma
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Gamma() ) );
	}
}


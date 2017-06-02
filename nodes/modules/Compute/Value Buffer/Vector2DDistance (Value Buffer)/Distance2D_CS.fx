#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float2> vector1Buffer, vector2Buffer;
float2 vector1Value, vector2Value = float2(0,1);
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Distance (uint3 i : SV_DispatchThreadID)
{
	if (i.x > threadCount) { return; }
	
	float Result = distance(sbLoad(vector1Buffer, vector1Value, i.x), sbLoad(vector2Buffer, vector2Value, i.x));
	
	RWValueBuffer[i.x] = Result;	
}





technique11 Distance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Distance() ) );
	}
}


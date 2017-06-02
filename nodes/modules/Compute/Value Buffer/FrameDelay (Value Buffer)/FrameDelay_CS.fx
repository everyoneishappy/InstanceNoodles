#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

bool toggle;

struct pingpong
{	
float ping;
float pong;
};

StructuredBuffer<pingpong> InputBuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS_Delay( uint3 dtid : SV_DispatchThreadID )
{
	if (toggle)
	{
		Output[dtid.x] = InputBuffer[dtid.x].pong;	
	}
	else
	{
		Output[dtid.x] = InputBuffer[dtid.x].ping;	
	}


}



technique11 FrameDelay
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Delay() ) );
	}
}

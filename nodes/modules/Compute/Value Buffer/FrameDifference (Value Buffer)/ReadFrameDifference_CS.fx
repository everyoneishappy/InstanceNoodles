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
void CS( uint3 dtid : SV_DispatchThreadID )
{
 	if (dtid.x >= threadCount) { return; }
	
	float frameDiff;
	if (toggle)
	{
		frameDiff = InputBuffer[dtid.x].ping - InputBuffer[dtid.x].pong;	
	}
	else
	{
		frameDiff = InputBuffer[dtid.x].pong - InputBuffer[dtid.x].ping;	
	}
	Output[dtid.x] = frameDiff;

}



technique11 FrameDifference
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

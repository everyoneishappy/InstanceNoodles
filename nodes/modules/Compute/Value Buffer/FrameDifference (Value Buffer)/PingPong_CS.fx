#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif
bool toggle;

struct pingpong
{	
float ping;
float pong;
};

StructuredBuffer<float> InputBuffer;
RWStructuredBuffer<pingpong> Output : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif


[numthreads(GROUPSIZE)]
void CS( uint3 dtid : SV_DispatchThreadID )
{
 	if (dtid.x >= threadCount) { return; }
	
	float v = InputBuffer[dtid.x % sbSize(InputBuffer)];
	
	if (toggle)
	{
		Output[dtid.x].ping = v;	
		return;
	}
	Output[dtid.x].pong = v;

}



technique11 FrameDifference
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

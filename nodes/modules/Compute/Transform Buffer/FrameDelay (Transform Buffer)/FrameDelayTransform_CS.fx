#include "..\..\..\Common\InstanceNoodles.fxh"
bool toggle;

struct pingpong
{	
float4x4 ping;
float4x4 pong;
};

StructuredBuffer<pingpong> InputBuffer;
RWStructuredBuffer<float4x4> Output : BACKBUFFER;

[numthreads(64, 1, 1)]
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

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 FrameDelay
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Delay() ) );
	}
}

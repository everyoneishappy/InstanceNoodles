#include "..\..\..\Common\InstanceNoodles.fxh"
bool toggle;

struct pingpong
{	
float2 ping;
float2 pong;
};

StructuredBuffer<float2> InputBuffer;
RWStructuredBuffer<pingpong> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS( uint3 dtid : SV_DispatchThreadID )
{
 	if (dtid.x >= threadCount) { return; }
	
	float2 v = InputBuffer[dtid.x % bSize(InputBuffer)];
	
	if (toggle)
	{
		Output[dtid.x].ping = v;	
		return;
	}
	Output[dtid.x].pong = v;

}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 FrameDifference
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

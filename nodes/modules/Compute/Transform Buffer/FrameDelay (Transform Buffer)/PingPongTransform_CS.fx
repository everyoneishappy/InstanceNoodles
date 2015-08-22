#include "..\..\..\Common\InstanceNoodles.fxh"
bool toggle;

struct pingpong
{	
float4x4 ping;
float4x4 pong;
};

StructuredBuffer<float4x4> InputBuffer;
RWStructuredBuffer<pingpong> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS( uint3 dtid : SV_DispatchThreadID )
{
 	if (dtid.x >= threadCount) { return; }
	
	float4x4 v = InputBuffer[dtid.x % bSize(InputBuffer)];
	
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

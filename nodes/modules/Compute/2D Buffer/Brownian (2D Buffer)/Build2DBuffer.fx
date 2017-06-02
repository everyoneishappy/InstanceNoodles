
StructuredBuffer<float4> posvel;
RWStructuredBuffer<float2> Output: BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; }

	Output[DTid.x] = posvel[DTid.x].xy;

}



technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

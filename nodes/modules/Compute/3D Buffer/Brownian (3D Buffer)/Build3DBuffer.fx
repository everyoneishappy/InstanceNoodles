struct particle
{
	float3 pos;
	float3 vel;
};

StructuredBuffer<particle> posvel;
RWStructuredBuffer<float3> Output: BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{

	if (DTid.x >= threadCount) { return; }
	Output[DTid.x] = posvel[DTid.x].pos;

	
}



technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

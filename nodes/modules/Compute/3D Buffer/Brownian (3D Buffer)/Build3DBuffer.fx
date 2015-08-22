struct particle
{
	float3 pos;
	float3 vel;
};

StructuredBuffer<particle> posvel;
RWStructuredBuffer<float3> Output: BACKBUFFER;
//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{


	Output[DTid.x] = posvel[DTid.x].pos;

	
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

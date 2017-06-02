

struct particle
{
	float3 pos;
	float3 vel;
};


bool reset;

//Reset Position (xy) and random damping (w)
StructuredBuffer<float4> resetData;


//RandomDirectionBuffer
StructuredBuffer<float3> rndDir;
int brwIndexShift;
float brwnStrenght;


RWStructuredBuffer<particle> Output: BACKBUFFER; 

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSConstantForce( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }
	if (reset)
	{
		Output[dtid.x].pos = resetData[dtid.x].xyz;
		Output[dtid.x].vel = 0;
	}

	else
	{
		float3 p = Output[dtid.x].pos;
		float3 v = Output[dtid.x].vel;

		//Velocity Damping:
		v *= resetData[dtid.x].w;
	

		// Brownian
		uint rndIndex = dtid.x + brwIndexShift;
		rndIndex = rndIndex % threadCount;
		float3 brwnForce = rndDir[rndIndex];
		v += brwnForce * brwnStrenght;
		
		

		Output[dtid.x].vel = v;
		Output[dtid.x].pos = p + v;
	}
}


technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

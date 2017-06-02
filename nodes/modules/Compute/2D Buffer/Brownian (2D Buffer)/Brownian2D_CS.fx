bool reset;


//Reset Position (xy) and random damping (w)
StructuredBuffer<float3> resetData;


//RandomDirectionBuffer
StructuredBuffer<float2> rndDir;
int brwIndexShift;
float brwnStrength;


RWStructuredBuffer<float4> Output: BACKBUFFER; 


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; }
	
	if (reset)
	{
		Output[DTid.x].xy = resetData[DTid.x].xy;
		Output[DTid.x].zw = 0;
	}

	else
	{
		float2 p = Output[DTid.x].xy;
		float2 v = Output[DTid.x].zw;

		//Velocity Damping:
		v *= resetData[DTid.x].z;
	

		// Brownian
		uint rndIndex = DTid.x + brwIndexShift;
		rndIndex = rndIndex % threadCount;
		float2 brwnForce = rndDir[rndIndex];
		v += brwnForce * brwnStrength;
		
		

		Output[DTid.x].zw = v;
		Output[DTid.x].xy = p + v;
		//bufferout[DTid.x]=Output[DTid.x].xy;
	}
}



technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}

#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


StructuredBuffer<float3> InputBuffer; 

//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float3> output : BACKBUFFER;
StructuredBuffer<float> resetBuffer; 
bool resetDefault;

StructuredBuffer<float3> inputPos;

uint vCount =3;
float vLength;
float damper;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS( uint3 dtid : SV_DispatchThreadID)
{ 
	//if (dtid.x >= threadCountBuffer.Load(0)) { return; }
	if (dtid.x >= threadCount) { return; }
	uint pCount = sbSize(inputPos);
	uint outID = dtid.x * vCount;

	bool reset = sbLoad(resetBuffer, resetDefault, dtid.x);
	if (reset) 
	{
		for( uint i = 0;i < vCount; i++ )
		output[outID+i] = inputPos[dtid.x];
		return;
	}
		

		float3 target = inputPos[dtid.x % pCount];
	float3 distVec = target - output[outID];

	output[outID] += (length(distVec)-vLength) * damper * normalize(distVec) ;
	
	for( uint i = 0;i < vCount-1; i++ )
	{
  		target = output[outID+i];
		distVec = target - output[outID+i+1];
		output[outID+i+1] += (length(distVec)-vLength) * damper * normalize(distVec) ;
		
	}
	
}


technique11 Verlet
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








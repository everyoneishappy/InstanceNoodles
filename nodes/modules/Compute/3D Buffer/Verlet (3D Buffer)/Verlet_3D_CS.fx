#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float3> InputBuffer; 

//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float3> output : BACKBUFFER;
bool reset;

StructuredBuffer<float3> inputPos;

int vCount =3;
float vLength;
float damper;





[numthreads(64, 1, 1)]
void CS( uint3 dtid : SV_DispatchThreadID)
{ 
	//if (dtid.x >= threadCountBuffer.Load(0)) { return; }
	if (dtid.x >= threadCount) { return; }
	uint pCount = bSize(inputPos);
	

	
	if (reset) 
	{
		output[dtid.x] = inputPos[floor(dtid.x/vCount)];
		return;
	}
		
	uint outID = dtid.x * vCount;
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








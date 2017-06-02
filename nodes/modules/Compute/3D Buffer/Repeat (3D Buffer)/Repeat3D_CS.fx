StructuredBuffer<float3> spreadBuffer;
RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;
int pointsize =8;
uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Repeat(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	uint count,dummy;	
	spreadBuffer.GetDimensions(count,dummy);
	
	uint newIndex = dtid.x % count;	
	RWValueBuffer[dtid.x] = spreadBuffer[newIndex];
	
}


[numthreads(GROUPSIZE)]
void CS_Point(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	uint count,dummy;	
	spreadBuffer.GetDimensions(count,dummy);
	
	uint newIndex = floor(dtid.x / pointsize % count);	
	RWValueBuffer[dtid.x] = spreadBuffer[newIndex];	
}

technique11 Repeat
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Repeat() ) );
	}
}

technique11 Point
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Point() ) );
	}
}




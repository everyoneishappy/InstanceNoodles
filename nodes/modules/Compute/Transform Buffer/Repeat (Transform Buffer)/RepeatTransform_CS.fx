StructuredBuffer<float4x4> spreadBuffer;
RWStructuredBuffer<float4x4> RWValueBuffer : BACKBUFFER;
int pointsize =8;
int threadCount;

[numthreads(64,1,1)]
void CS_Repeat(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	uint count,dummy;	
	spreadBuffer.GetDimensions(count,dummy);
	
	uint newIndex = dtid.x % count;	
	RWValueBuffer[dtid.x] = spreadBuffer[newIndex];
	
}


[numthreads(64,1,1)]
void CS_Point(uint3 dtid : SV_DispatchThreadID)
{
	
	if (dtid.x >= threadCount) { return; }
	uint count,dummy;	
	spreadBuffer.GetDimensions(count,dummy);
	
	uint newIndex = floor(dtid.x / pointsize);	
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




RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;
int perInstanceVertCount;
int buffersize;

[numthreads(128,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > buffersize) { return; }
	RWValueBuffer[dtid.x] = floor(dtid.x / perInstanceVertCount);
}


technique11 IIDgen
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



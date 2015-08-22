RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;
ByteAddressBuffer IID;
int buffersize;

[numthreads(128,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > buffersize) { return; }
	RWValueBuffer[dtid.x] = IID.Load((dtid.x * 36)+32); // assuming pos, norm, uv before IID slot
}




technique11 raw2float
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



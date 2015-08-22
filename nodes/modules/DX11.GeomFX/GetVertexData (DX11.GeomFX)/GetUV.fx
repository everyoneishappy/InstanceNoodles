RWStructuredBuffer<float2> RWValueBuffer : BACKBUFFER;
ByteAddressBuffer vData;
int buffersize;

[numthreads(256,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > buffersize) { return; }
	RWValueBuffer[dtid.x] = float2(asfloat(vData.Load(dtid.x * 32 + 24)),asfloat(vData.Load(dtid.x * 32 + 28)));
}




technique11 UV
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



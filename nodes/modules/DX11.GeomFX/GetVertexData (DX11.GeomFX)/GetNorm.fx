RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;
ByteAddressBuffer vData;
int buffersize;

[numthreads(256,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > buffersize) { return; }
	float3 norm = float3(asfloat(vData.Load(dtid.x * 32 + 12)), asfloat(vData.Load(dtid.x * 32+16)), asfloat(vData.Load(dtid.x * 32+20)));
	RWValueBuffer[dtid.x] = normalize(norm);
}




technique11 Norm
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



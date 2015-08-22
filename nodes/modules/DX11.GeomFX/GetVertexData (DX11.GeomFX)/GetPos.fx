RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;
ByteAddressBuffer vData;
int buffersize;

[numthreads(256,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x > buffersize) { return; }
	float3 pos = float3(asfloat(vData.Load(dtid.x * 32)), asfloat(vData.Load(dtid.x * 32+4)), asfloat(vData.Load(dtid.x * 32+8)));
	RWValueBuffer[dtid.x] = pos;
}




technique11 Pos
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



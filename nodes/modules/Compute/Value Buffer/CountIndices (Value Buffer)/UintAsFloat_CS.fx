


StructuredBuffer<uint> uintBuffer;
RWStructuredBuffer<float> output : BACKBUFFER;






[numthreads(64, 1, 1)]
void CS_Clear( uint3 dtid : SV_DispatchThreadID)
{ 
	output[dtid.x] = uintBuffer[dtid.x];
}




technique11 Convert
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );
	}
}



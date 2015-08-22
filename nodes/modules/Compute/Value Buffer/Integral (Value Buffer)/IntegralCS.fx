



RWStructuredBuffer<float> output : BACKBUFFER;
float buffersize;
StructuredBuffer<float> valueBuffer;



[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= buffersize) { return; }

	float sum = 0;
	for( uint i = 0;i < dtid.x; i++ )
	{
  		sum += valueBuffer[i];
	} 
	output[dtid.x] = sum;
}




technique11 Integral
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}




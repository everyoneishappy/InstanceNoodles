
RWStructuredBuffer<float> output : BACKBUFFER;
Texture2D<float> tex;
SamplerState sPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Border;
    AddressV = Border;
};

#ifndef BIGNUMBER
#define BIGNUMBER 99999999.0
#endif

[numthreads(1, 1, 1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{ 
	output[dtid.x] = tex.SampleLevel(sPoint, 0, 0);
}



technique11 Result
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;

//Texture we want to read from
Texture2DArray tex <string uiname="Texture";>;

//Buffer containing uvs for sampling
StructuredBuffer<float2> bUV <string uiname="UV Buffer";>;
StructuredBuffer<float> bTexIndex <string uiname="Texture Index Buffer";>;

SamplerState mySampler 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

[numthreads(64, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float4 sample = tex.SampleLevel(mySampler,coords,0);
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	
	rwbuffer[i.x] = sample;
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








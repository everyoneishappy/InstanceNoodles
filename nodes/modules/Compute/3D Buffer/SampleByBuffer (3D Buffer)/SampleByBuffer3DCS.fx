#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> rwbuffer : BACKBUFFER;

//Texture we want to read from
Texture2DArray tex <string uiname="Texture";>;

//Buffer containing uvs for sampling
StructuredBuffer<float2> uv <string uiname="UV Buffer";>;
StructuredBuffer<float> TextureIndexBuffer <string uiname="Texture Index Buffer";>;

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
	
	uint uvCount = bSize(uv);
	uint texCount = bSize(TextureIndexBuffer);
	
	float3 coords = float3(uv[i.x % uvCount],TextureIndexBuffer [i.x % uvCount]);
	
	float3 sample = tex.SampleLevel(mySampler,coords,0).xyz;
	
	//sample = isinf(sample) ? rwbuffer[i.x] : sample;
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








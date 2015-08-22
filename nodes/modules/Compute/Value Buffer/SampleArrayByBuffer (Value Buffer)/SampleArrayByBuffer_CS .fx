#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float> rwbuffer : BACKBUFFER;

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
void CSLuminance( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float3 sample = tex.SampleLevel(mySampler,coords,0).rgb;
	
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	float lum = log(1 + 0.27*sample.r + 0.67*sample.g + 0.06*sample.b);
	rwbuffer[i.x] = lum;
}


[numthreads(64, 1, 1)]
void CSred( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float sample = tex.SampleLevel(mySampler,coords,0).r;
	
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	
	rwbuffer[i.x] = sample;
}


[numthreads(64, 1, 1)]
void CSGreen( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float sample = tex.SampleLevel(mySampler,coords,0).g;
	
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	
	rwbuffer[i.x] = sample;
}


[numthreads(64, 1, 1)]
void CSBlue( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float sample = tex.SampleLevel(mySampler,coords,0).b;
	
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	
	rwbuffer[i.x] = sample;
}


[numthreads(64, 1, 1)]
void CSAlpha( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 coords = float3(bLoad(bUV,.5,i.x), bLoad(bTexIndex, 0, i.x));
	
	float sample = tex.SampleLevel(mySampler,coords,0).x;
	
	sample = isinf(sample) ? rwbuffer[i.x] : sample;
	sample = isnan(sample) ? rwbuffer[i.x] : sample;

	
	rwbuffer[i.x] = sample;
}









technique11 Red
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSred() ) );
	}
}

technique11 Green
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSGreen() ) );
	}
}

technique11 Blue
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSBlue() ) );
	}
}

technique11 Alpha
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSAlpha() ) );
	}
}

technique11 Luminance
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSLuminance() ) );
	}
}
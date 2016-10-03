

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;
float3 InvVolumeSize : INVTARGETSIZE;


Texture3D<float> inputVolume;
SamplerState samp <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};


[numthreads(8, 8, 8)]
void CS_Resize( uint3 ti : SV_DispatchThreadID)
{ 
	float3 uvw = ti;
	uvw *= InvVolumeSize;
	
	RWDistanceVolume[ti] = inputVolume.SampleLevel(samp, uvw, 0);
	
}

technique11 ResizeVolume
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Resize() ) );
	}
}





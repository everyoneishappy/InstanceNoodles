///////////////////////////////////////////////////////////////////////
Texture2D mask;
SamplerState linearSampler <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

StructuredBuffer<float> radiusSB;
float extrude (float3 p, float height)
{
	return max(mask.SampleLevel(linearSampler, p.xz+.5, 0).x, abs(p.y) - height/2 );
}
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, radCount, maxCount;





[numthreads(8, 8, 8)]
void CS_SDF( uint3 ti : SV_DispatchThreadID)
{ 
	float3 p = ti;
	p *= InvVolumeSize;
	p -= 0.5f;
	RWDistanceVolume[ti] = 1.0;
	float3 tp;
	for(uint i=0; i<maxCount; i++)
	{
		tp = mul(float4(p,1),InvTransform[i%tranformCount]).xyz;
		float radius = radiusSB[i % radCount];
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], extrude(tp, radius));
	}
}

technique11 Extrude
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SDF() ) );
	}
}





///////////////////////////////////////////////////////////////////////
StructuredBuffer<float> radiusSB;
float sphere (float3 p, float radius)
{
	return length(p)-radius; 
}
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, radCount, maxCount;
//float3 VolumeSize : TARGETSIZE;





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
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], sphere(tp, radius));
	}
}

technique11 PrimitiveDistanceField
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SDF() ) );
	}
}





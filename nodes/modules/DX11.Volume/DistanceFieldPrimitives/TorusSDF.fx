///////////////////////////////////////////////////////////////////////
StructuredBuffer<float2> sizeSB;
float torus(float3 p, float smallRadius, float largeRadius) 
{
	return length(float2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, sizeCount, maxCount;


[numthreads(8, 8, 8)]
void CS_Torus( uint3 ti : SV_DispatchThreadID)
{ 
	float3 p = ti;
	p *= InvVolumeSize;
	p -= 0.5f;
	RWDistanceVolume[ti] = 1.0;
	float3 tp;
	for(uint i=0; i<maxCount; i++)
	{
		tp = mul(float4(p,1),InvTransform[i%tranformCount]).xyz;
		float2 size = sizeSB[i % sizeCount];
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], torus(tp, size.x, size.y));
	}
}




technique11 Torus
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Torus() ) );
	}
}





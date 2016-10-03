///////////////////////////////////////////////////////////////////////
StructuredBuffer<float2> sizeSB;
float cylinder(float3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, sizeCount, maxCount;


[numthreads(8, 8, 8)]
void CS_Cylinder( uint3 ti : SV_DispatchThreadID)
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
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], cylinder(tp, size.x, size.y));
	}
}




technique11 Cylinder
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Cylinder() ) );
	}
}





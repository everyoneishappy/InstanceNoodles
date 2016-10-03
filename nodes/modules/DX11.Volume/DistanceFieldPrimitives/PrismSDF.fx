///////////////////////////////////////////////////////////////////////
StructuredBuffer<float2> sizeSB;
float prism( float3 p, float2 h )
{
    float3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, sizeCount, maxCount;


[numthreads(8, 8, 8)]
void CS_Prism( uint3 ti : SV_DispatchThreadID)
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
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], prism(tp, size));
	}
}




technique11 Prism
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Prism() ) );
	}
}





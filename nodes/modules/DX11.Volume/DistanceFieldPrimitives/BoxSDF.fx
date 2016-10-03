///////////////////////////////////////////////////////////////////////
StructuredBuffer<float3> sizeSB;
float box(float3 p, float3 b)
{
	float3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float rad = 0.1;
float RBox(float3 p,float3 b,float rad ) { return length(max(abs(p)-b+rad,0.0))-rad; }
///////////////////////////////////////////////////////////////////////

RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

StructuredBuffer<float4x4> InvTransform;
float3 InvVolumeSize : INVTARGETSIZE;
uint tranformCount, sizeCount, maxCount;
//float3 VolumeSize : TARGETSIZE;





[numthreads(8, 8, 8)]
void CS_Box( uint3 ti : SV_DispatchThreadID)
{ 
	float3 p = ti;
	p *= InvVolumeSize;
	p -= 0.5f;
	RWDistanceVolume[ti] = 1.0;
	float3 tp;
	for(uint i=0; i<maxCount; i++)
	{
		tp = mul(float4(p,1),InvTransform[i%tranformCount]).xyz;
		float3 size = sizeSB[i % sizeCount];
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], box(tp, size));
	}
}

[numthreads(8, 8, 8)]
void CS_RoundBox( uint3 ti : SV_DispatchThreadID)
{ 
	float3 p = ti;
	p *= InvVolumeSize;
	p -= 0.5f;
	RWDistanceVolume[ti] = 1.0;
	float3 tp;
	for(uint i=0; i<maxCount; i++)
	{
		tp = mul(float4(p,1),InvTransform[i%tranformCount]).xyz;
		float3 size = sizeSB[i % sizeCount];
		RWDistanceVolume[ti] = min(RWDistanceVolume[ti], RBox(tp, size, rad));
	}
}


technique11 Box
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Box() ) );
	}
}

technique11 RoundBox
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_RoundBox() ) );
	}
}



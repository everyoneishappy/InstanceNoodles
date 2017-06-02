RWTexture3D<float> RWDistanceVolume : BACKBUFFER;
float3 InvVolumeSize : INVTARGETSIZE;
float4x4 InvTransform;

#include <packs\InstanceNoodles\nodes\modules\Common\NoodleNoise.fxh>
iFractalNoise fractalType <string linkclass="Noise,FBM,Turbulence,Ridge";>;
iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;
float freq, pers, lacun;
int oct;
float offset = 0;

[numthreads(8, 8, 8)]
void CS_Perlin( uint3 dtid : SV_DispatchThreadID )
{
	float3 p = dtid;
	p *= InvVolumeSize; // 0 to 1
	p -= 0.5f;			// -.05 to 0.5
	p = mul(float4(p,1),InvTransform).xyz;
	p += .5;
	
	RWDistanceVolume[dtid] = fractalType.Perlin(p, freq, pers, lacun, oct) + offset;
}

[numthreads(8, 8, 8)]
void CS_Simplex( uint3 dtid : SV_DispatchThreadID )
{
	float3 p = dtid;
	p *= InvVolumeSize; // 0 to 1
	p -= 0.5f;			// -.05 to 0.5
	p = mul(float4(p,1),InvTransform).xyz;
	p += .5;
		
	RWDistanceVolume[dtid] = fractalType.Simplex(p, freq, pers, lacun, oct)+ offset;
}

[numthreads(8, 8, 8)]
void CS_FastWorley( uint3 dtid : SV_DispatchThreadID )
{
	float3 p = dtid;
	p *= InvVolumeSize; // 0 to 1
	p -= 0.5f;			// -.05 to 0.5
	p = mul(float4(p,1),InvTransform).xyz;
	p += .5;
		
	RWDistanceVolume[dtid] = fractalType.FastWorley(p, freq, pers, lacun, oct)+ offset;
}

[numthreads(8, 8, 8)]
void CS_Worley( uint3 dtid : SV_DispatchThreadID )
{
	float3 p = dtid;
	p *= InvVolumeSize; // 0 to 1
	p -= 0.5f;			// -.05 to 0.5
	p = mul(float4(p,1),InvTransform).xyz;
	p += .5;
		
	RWDistanceVolume[dtid] = fractalType.Worley(cellDistance, cellFunction, p, freq, pers, lacun, oct)+ offset;
}


////////////////////////////////////////////////////////////////////////////////////////////////

technique11 Perlin3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Perlin() ) );
	}
}

technique11 Simplex3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Simplex() ) );
	}
}

technique11 FastWorley3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_FastWorley() ) );
	}
}

technique11 Worley3D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Worley() ) );
	}
}

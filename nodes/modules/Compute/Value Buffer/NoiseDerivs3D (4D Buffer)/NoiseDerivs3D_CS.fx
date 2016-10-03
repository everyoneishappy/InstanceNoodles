#include <packs\InstanceNoodles\nodes\modules\Common\InstanceNoodles.fxh>
#include <packs\InstanceNoodles\nodes\modules\Common\NoodleNoise.fxh>
iFractalNoise fractalType <string linkclass="Noise,FBM,Turbulence,Ridge";>;

iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;

float freq, pers, lacun;
int oct;
float3 offset;

StructuredBuffer<float3> XYZbuffer;
RWStructuredBuffer<float4> Output : BACKBUFFER;




[numthreads(64, 1, 1)]
void CS_Perlin( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float3 v = XYZbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.PerlinD(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_Simplex( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float3 v = XYZbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.SimplexD(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_FastWorley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float3 v = XYZbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.FastWorleyD(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_Worley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float3 v = XYZbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.WorleyD(cellDistance, cellFunction, v+offset, freq, pers, lacun, oct);
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

#include <packs\InstanceNoodles\nodes\modules\Common\InstanceNoodles.fxh>
#include <packs\InstanceNoodles\nodes\modules\Common\NoodleNoise.fxh>
iFractalNoise fractalType <string linkclass="Noise,FBM,Turbulence,Ridge";>;

iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;

float freq, pers, lacun;
int oct;
float2 offset;

StructuredBuffer<float2> XYbuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;




[numthreads(64, 1, 1)]
void CS_Perlin( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 v = XYbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.Perlin(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_Simplex( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 v = XYbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.Simplex(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_FastWorley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 v = XYbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.FastWorley(v+offset, freq, pers, lacun, oct);
}

[numthreads(64, 1, 1)]
void CS_Worley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 v = XYbuffer[dtid.x];
		
	Output[dtid.x] = fractalType.Worley(cellDistance, cellFunction, v+offset, freq, pers, lacun, oct);
}


////////////////////////////////////////////////////////////////////////////////////////////////

technique11 Perlin2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Perlin() ) );
	}
}

technique11 Simplex2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Simplex() ) );
	}
}

technique11 FastWorley2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_FastWorley() ) );
	}
}

technique11 Worley2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Worley() ) );
	}
}


#ifndef NOISE_FXH
#include <packs\happy.fxh\noise.fxh>
#endif


iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;

float freq = 2.0;
float center;
float amp = 1.0;
float2 domainOffset;


StructuredBuffer<float2> XYbuffer;
RWStructuredBuffer<float> Output : BACKBUFFER;




uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_RandomNoise( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = random(p) * amp + center;
}

[numthreads(GROUPSIZE)]
void CS_ValueNoise( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = valueNoise(p) * amp + center;
}

[numthreads(GROUPSIZE)]
void CS_Perlin( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = perlin(p) * amp + center;
}

[numthreads(GROUPSIZE)]
void CS_Simplex( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = simplex(p) * amp + center;
}

[numthreads(GROUPSIZE)]
void CS_FastWorley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = worleyFast(p) * amp + center;
}

[numthreads(GROUPSIZE)]
void CS_Worley( uint3 dtid : SV_DispatchThreadID )
{
	if (dtid.x >= threadCount) { return; }

	float2 p = XYbuffer[dtid.x] * freq + domainOffset;
	Output[dtid.x] = worley(p, cellDistance, cellFunction) * amp + center;
}


////////////////////////////////////////////////////////////////////////////////////////////////

technique11 RandomNoise2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_RandomNoise() ) );
	}
}

technique11 ValueNoise2D
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_ValueNoise() ) );
	}
}

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


#include <packs\InstanceNoodles\nodes\modules\Common\InstanceNoodles.fxh>
#include <packs\InstanceNoodles\nodes\modules\Common\NoodleNoise.fxh>
StructuredBuffer<float3> valueBuffer;
RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;

iFractalNoise fractalType <string linkclass="Noise,FBM,Turbulence,Ridge";>;
iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;
float freq, pers, lacun;
int oct;
float3 offset;


uint pathSize;
StructuredBuffer<float> stepAmtBuffer;
float stepAmtDefualt = 0.01;

[numthreads(64,1,1)]
void CS_Perlin(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	float3 currentPoint = valueBuffer[dtid.x % bSize(valueBuffer)];
	float stepAmt = bLoad(stepAmtBuffer, stepAmtDefualt, dtid.x);
	for (uint i = 0; i < pathSize; i++)
	{
		RWValueBuffer[dtid.x * pathSize + i] = currentPoint;
		float3 noiseNudge = float3(fractalType.Perlin(currentPoint+offset, freq, pers, lacun, oct), fractalType.Perlin(currentPoint+offset+86.7, freq, pers, lacun, oct), fractalType.Perlin(currentPoint+offset-23.3, freq, pers, lacun, oct));
		//float3 noiseNudge = float3(fractalType.PerlinD(currentPoint+offset, freq, pers, lacun, oct).yzw);
		currentPoint += noiseNudge * stepAmt;
	}
}

[numthreads(64,1,1)]
void CS_Simplex(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	float3 currentPoint = valueBuffer[dtid.x % bSize(valueBuffer)];
	float stepAmt = bLoad(stepAmtBuffer, stepAmtDefualt, dtid.x);
	for (uint i = 0; i < pathSize; i++)
	{
		RWValueBuffer[dtid.x * pathSize + i] = currentPoint;
		float3 noiseNudge = float3(fractalType.Simplex(currentPoint+offset, freq, pers, lacun, oct), fractalType.Simplex(currentPoint+offset+86.7, freq, pers, lacun, oct), fractalType.Simplex(currentPoint+offset-23.3, freq, pers, lacun, oct));
		currentPoint += noiseNudge * stepAmt;
	}
}

[numthreads(64,1,1)]
void CS_FastWorley(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	float3 currentPoint = valueBuffer[dtid.x % bSize(valueBuffer)];
	float stepAmt = bLoad(stepAmtBuffer, stepAmtDefualt, dtid.x);
	for (uint i = 0; i < pathSize; i++)
	{
		RWValueBuffer[dtid.x * pathSize + i] = currentPoint;
		float3 noiseNudge = float3(fractalType.FastWorley(currentPoint+offset, freq, pers, lacun, oct), fractalType.FastWorley(currentPoint+offset+86.7, freq, pers, lacun, oct), fractalType.FastWorley(currentPoint+offset-23.3, freq, pers, lacun, oct));
		currentPoint += noiseNudge * stepAmt;
	}
}

[numthreads(64,1,1)]
void CS_Worley(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	float3 currentPoint = valueBuffer[dtid.x % bSize(valueBuffer)];
	float stepAmt = bLoad(stepAmtBuffer, stepAmtDefualt, dtid.x);
	for (uint i = 0; i < pathSize; i++)
	{
		RWValueBuffer[dtid.x * pathSize + i] = currentPoint;
		//float3 noiseNudge = float3(fractalType.Worley(cellDistance, cellFunction, currentPoint+offset, freq, pers, lacun, oct), fractalType.Worley(cellDistance, cellFunction, currentPoint+offset+86.7, freq, pers, lacun, oct), fractalType.Worley(cellDistance, cellFunction, currentPoint+offset-23.3, freq, pers, lacun, oct));
		float3 noiseNudge = float3(fractalType.WorleyD(cellDistance, cellFunction, currentPoint+offset, freq, pers, lacun, oct).yzw);
		currentPoint += noiseNudge * stepAmt;
	}
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







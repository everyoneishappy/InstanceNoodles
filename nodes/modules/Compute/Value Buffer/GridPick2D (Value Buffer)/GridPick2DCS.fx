#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float> output : BACKBUFFER;

float areaSize = 10;
#define r areaSize/2
int gridRes = 5;
StructuredBuffer<float2> bPoints;

float2 MapClamp2(float2 Input, float InMin, float InMax, float OutMin, float OutMax)
		{
		float range = InMax - InMin;
		float2 normalized = (Input - InMin) / range;	
	    float2 output = OutMin + normalized * (OutMax - OutMin);
		float minV = min(OutMin,OutMax);
		float maxV = max(OutMin, OutMax);
	    output = min(max(output, minV), maxV);
		return output ;
		}

[numthreads(64,1,1)]
void CS(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	// get buffer count
	uint pCount,dummy;	
	bPoints.GetDimensions(pCount,dummy);
	
	// set default value for buffer if empty
	float2 pos =0;
	if(pCount>0) pos = bPoints[dtid.x % pCount];
	
	float2 idXY = floor(MapClamp2(pos, -r, r, 0, gridRes));

	float2 binID = idXY.x + (idXY.y * gridRes);
	output[dtid.x] = binID;
}



technique11 GetIndices
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



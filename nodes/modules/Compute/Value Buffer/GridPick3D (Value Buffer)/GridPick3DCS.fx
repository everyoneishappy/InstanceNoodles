#include "..\..\..\Common\InstanceNoodles.fxh"


RWStructuredBuffer<float> output : BACKBUFFER;

float areaSize = 10;
#define r areaSize/2
int gridRes = 5;
StructuredBuffer<float3> bPoints;

float3 MapClamp3(float3 Input, float InMin, float InMax, float OutMin, float OutMax)
		{
		float range = InMax - InMin;
		float3 normalized = (Input - InMin) / range;	
	    float3 output = OutMin + normalized * (OutMax - OutMin);
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
	float3 pos =0;
	if(pCount>0) pos = bPoints[dtid.x % pCount];
	
	uint3 idXYZ = floor(MapClamp3(pos, -r, r, 0, gridRes));

	uint binID = idXYZ.x + (idXYZ.y * gridRes) + (idXYZ.z * gridRes * gridRes);
	output[dtid.x] = binID;
}



technique11 GetIndices
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}



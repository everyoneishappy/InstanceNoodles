#include "..\..\..\Common\InstanceNoodles.fxh"

#define PI 3.14159265
#define dlong PI*(3-sqrt(5.0))

RWStructuredBuffer<float3> output : BACKBUFFER;



float factorDefault, radiusDefault;
float3 inputDefault;

StructuredBuffer<float> factorBuffer, radiusBuffer;
StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;
StructuredBuffer<float3> inputBuffer;

[numthreads(64, 1, 1)]
void CS_Spherical ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y;
	
	float factor = bLoad(factorBuffer, factorDefault, bin);
	float radius = bLoad(radiusBuffer, radiusDefault, bin);
	float3 input = bLoad(inputBuffer, inputDefault, bin);
	
	float3 result;
	
	float dz = (factor*2.0)/binsize;	
	float z  = 1.0 - dz/2.0;
	z = z - id * dz;	
	float l = id * dlong;
	float r = sqrt(1.0-z*z);
	
	result.x = cos(l)*r*radius;
	result.y = sin(l)*r*radius;
	result.z = z * radius;
	output[dtid.x] = result + input;
}


technique11 Spherical
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Spherical() ) );
	}
}














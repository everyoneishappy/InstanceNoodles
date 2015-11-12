#include "..\..\..\Common\InstanceNoodles.fxh"
#include "..\..\..\Common\Map.fxh"

StructuredBuffer<float>  ValueBuffer;
float initialDefault;
StructuredBuffer<float>  initialBuffer;

float minDefault = 0;
float maxDefault = 1;
StructuredBuffer<float> minBuffer;
StructuredBuffer<float> maxBuffer;

bool initializeDefault = false;
StructuredBuffer<float> initializeBuffer;

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64,1,1)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	if (bLoad(initializeBuffer, initializeDefault, i.x))
	{
		Output[i.x] = bLoad(initialBuffer, initialDefault, i.x);
		return;
	}
	float Value = Output[i.x] + bLoad(ValueBuffer, 0, i.x);
	float mapMin = bLoad(minBuffer, minDefault, i.x);
	float mapMax = bLoad(maxBuffer, maxDefault, i.x);


	Output[i.x] = map( Value,  mapMin,  mapMax,  mapMin,  mapMax);

}





technique11 Intergrate
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Map() ) );
	}
}



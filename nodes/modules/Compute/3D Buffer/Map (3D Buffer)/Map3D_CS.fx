#include "..\..\..\Common\InstanceNoodles.fxh"
#include "..\..\..\Common\Map.fxh"

StructuredBuffer<float3>  ValueBuffer;
StructuredBuffer<float3> InMinBuffer;
StructuredBuffer<float3> InMaxBuffer;
StructuredBuffer<float3>OutMinBuffer;
StructuredBuffer<float3>OutMaxBuffer;

float3 inMinValues = 0;
float3 inMaxValues = 1;
float3 outMinValues = 0;
float3 outMaxValues = 1;

RWStructuredBuffer<float3> Output : BACKBUFFER;






[numthreads(64,1,1)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float3 Value = bLoad(ValueBuffer,0, i.x);
	float3 InMin = bLoad(InMinBuffer, inMinValues, i.x);
	float3 InMax = bLoad(InMaxBuffer,inMaxValues, i.x);
	float3 OutMin = bLoad(OutMinBuffer,outMinValues, i.x);
	float3 OutMax = bLoad(OutMaxBuffer,outMaxValues, i.x);
	
	Output[i.x] = map( Value,  InMin,  InMax,  OutMin,  OutMax);
}





technique11 Map
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Map() ) );
	}
}



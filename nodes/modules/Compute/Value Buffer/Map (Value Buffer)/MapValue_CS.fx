#include "..\..\..\Common\InstanceNoodles.fxh"
#include "Map.fxh"

StructuredBuffer<float>  ValueBuffer;
StructuredBuffer<float> InMinBuffer;
StructuredBuffer<float> InMaxBuffer;
StructuredBuffer<float>OutMinBuffer;
StructuredBuffer<float>OutMaxBuffer;

float4 DefaultMapValues <string uiname="XYZW InMinMax OutMinMax";> = float4(0.,1.,0.,1);

RWStructuredBuffer<float> Output : BACKBUFFER;

[numthreads(64,1,1)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float Value = bLoad(ValueBuffer, 0, i.x);
	float InMin = bLoad(InMinBuffer, DefaultMapValues.x, i.x);
	float InMax = bLoad(InMaxBuffer, DefaultMapValues.y, i.x);
	float OutMin = bLoad(OutMinBuffer, DefaultMapValues.z, i.x);
	float OutMax = bLoad(OutMaxBuffer, DefaultMapValues.w, i.x);

	Output[i.x] = map( Value,  InMin,  InMax,  OutMin,  OutMax);
}





technique11 Map
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Map() ) );
	}
}



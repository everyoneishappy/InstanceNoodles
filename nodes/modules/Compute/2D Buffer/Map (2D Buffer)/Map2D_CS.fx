#include "..\..\..\Common\InstanceNoodles.fxh"
#include "..\..\..\Common\Map.fxh"

StructuredBuffer<float2>  ValueBuffer;
StructuredBuffer<float2> InMinBuffer;
StructuredBuffer<float2> InMaxBuffer;
StructuredBuffer<float2>OutMinBuffer;
StructuredBuffer<float2>OutMaxBuffer;

float4 xDefaultMapValues <string uiname="X InMinMax OutMinMax";> = float4(0.,1.,0.,1);
float4 yDefaultMapValues <string uiname="Y InMinMax OutMinMax";> = float4(0.,1.,0.,1);

RWStructuredBuffer<float2> Output : BACKBUFFER;






[numthreads(64,1,1)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float2 Value = bLoad(ValueBuffer,0, i.x);
	float2 InMin = bLoad(InMinBuffer,float2(xDefaultMapValues.x, yDefaultMapValues.x), i.x);
	float2 InMax = bLoad(InMaxBuffer,float2(xDefaultMapValues.y, yDefaultMapValues.y), i.x);
	float2 OutMin = bLoad(OutMinBuffer,float2(xDefaultMapValues.z, yDefaultMapValues.z), i.x);
	float2 OutMax = bLoad(OutMaxBuffer,float2(xDefaultMapValues.w, yDefaultMapValues.w), i.x);
	
	Output[i.x] = map( Value,  InMin,  InMax,  OutMin,  OutMax);
}





technique11 Map
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Map() ) );
	}
}



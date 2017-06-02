#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef MAP_FXH
#include <packs\happy.fxh\map.fxh>
#endif

StructuredBuffer<float>  ValueBuffer;
StructuredBuffer<float> InMinBuffer;
StructuredBuffer<float> InMaxBuffer;
StructuredBuffer<float>OutMinBuffer;
StructuredBuffer<float>OutMaxBuffer;

float4 DefaultMapValues <string uiname="XYZW InMinMax OutMinMax";> = float4(0.,1.,0.,1);

RWStructuredBuffer<float> Output : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float Value = sbLoad(ValueBuffer, 0, i.x);
	float InMin = sbLoad(InMinBuffer, DefaultMapValues.x, i.x);
	float InMax = sbLoad(InMaxBuffer, DefaultMapValues.y, i.x);
	float OutMin = sbLoad(OutMinBuffer, DefaultMapValues.z, i.x);
	float OutMax = sbLoad(OutMaxBuffer, DefaultMapValues.w, i.x);

	Output[i.x] = map(Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapClamp(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float Value = sbLoad(ValueBuffer, 0, i.x);
	float InMin = sbLoad(InMinBuffer, DefaultMapValues.x, i.x);
	float InMax = sbLoad(InMaxBuffer, DefaultMapValues.y, i.x);
	float OutMin = sbLoad(OutMinBuffer, DefaultMapValues.z, i.x);
	float OutMax = sbLoad(OutMaxBuffer, DefaultMapValues.w, i.x);

	Output[i.x] = mapClamp(Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapWrap(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float Value = sbLoad(ValueBuffer, 0, i.x);
	float InMin = sbLoad(InMinBuffer, DefaultMapValues.x, i.x);
	float InMax = sbLoad(InMaxBuffer, DefaultMapValues.y, i.x);
	float OutMin = sbLoad(OutMinBuffer, DefaultMapValues.z, i.x);
	float OutMax = sbLoad(OutMaxBuffer, DefaultMapValues.w, i.x);

	Output[i.x] = mapWrap(Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapMirror(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float Value = sbLoad(ValueBuffer, 0, i.x);
	float InMin = sbLoad(InMinBuffer, DefaultMapValues.x, i.x);
	float InMax = sbLoad(InMaxBuffer, DefaultMapValues.y, i.x);
	float OutMin = sbLoad(OutMinBuffer, DefaultMapValues.z, i.x);
	float OutMax = sbLoad(OutMaxBuffer, DefaultMapValues.w, i.x);

	Output[i.x] = mapMirror( Value,  InMin,  InMax,  OutMin,  OutMax);
}


technique11 MapFloat
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Map() ) );
	}
}


technique11 MapClamp
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_MapClamp() ) );
	}
}

technique11 MapWrap
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_MapWrap() ) );
	}
}

technique11 MapMirror
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_MapMirror() ) );
	}
}
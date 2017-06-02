#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef MAP_FXH
#include <packs\happy.fxh\map.fxh>
#endif

StructuredBuffer<float2>  ValueBuffer;
StructuredBuffer<float2> InMinBuffer;
StructuredBuffer<float2> InMaxBuffer;
StructuredBuffer<float2>OutMinBuffer;
StructuredBuffer<float2>OutMaxBuffer;

float4 xDefaultMapValues <string uiname="X InMinMax OutMinMax";> = float4(0.,1.,0.,1);
float4 yDefaultMapValues <string uiname="Y InMinMax OutMinMax";> = float4(0.,1.,0.,1);

RWStructuredBuffer<float2> Output : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float2 Value = sbLoad(ValueBuffer,0, i.x);
	float2 InMin = sbLoad(InMinBuffer,float2(xDefaultMapValues.x, yDefaultMapValues.x), i.x);
	float2 InMax = sbLoad(InMaxBuffer,float2(xDefaultMapValues.y, yDefaultMapValues.y), i.x);
	float2 OutMin = sbLoad(OutMinBuffer,float2(xDefaultMapValues.z, yDefaultMapValues.z), i.x);
	float2 OutMax = sbLoad(OutMaxBuffer,float2(xDefaultMapValues.w, yDefaultMapValues.w), i.x);
	
	Output[i.x] = map( Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapClamp(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float2 Value = sbLoad(ValueBuffer,0, i.x);
	float2 InMin = sbLoad(InMinBuffer,float2(xDefaultMapValues.x, yDefaultMapValues.x), i.x);
	float2 InMax = sbLoad(InMaxBuffer,float2(xDefaultMapValues.y, yDefaultMapValues.y), i.x);
	float2 OutMin = sbLoad(OutMinBuffer,float2(xDefaultMapValues.z, yDefaultMapValues.z), i.x);
	float2 OutMax = sbLoad(OutMaxBuffer,float2(xDefaultMapValues.w, yDefaultMapValues.w), i.x);
	
	Output[i.x] = mapClamp( Value,  InMin,  InMax,  OutMin,  OutMax);
}


[numthreads(GROUPSIZE)]
void CS_MapWrap(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float2 Value = sbLoad(ValueBuffer,0, i.x);
	float2 InMin = sbLoad(InMinBuffer,float2(xDefaultMapValues.x, yDefaultMapValues.x), i.x);
	float2 InMax = sbLoad(InMaxBuffer,float2(xDefaultMapValues.y, yDefaultMapValues.y), i.x);
	float2 OutMin = sbLoad(OutMinBuffer,float2(xDefaultMapValues.z, yDefaultMapValues.z), i.x);
	float2 OutMax = sbLoad(OutMaxBuffer,float2(xDefaultMapValues.w, yDefaultMapValues.w), i.x);
	
	Output[i.x] = mapWrap( Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapMirror(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float2 Value = sbLoad(ValueBuffer,0, i.x);
	float2 InMin = sbLoad(InMinBuffer,float2(xDefaultMapValues.x, yDefaultMapValues.x), i.x);
	float2 InMax = sbLoad(InMaxBuffer,float2(xDefaultMapValues.y, yDefaultMapValues.y), i.x);
	float2 OutMin = sbLoad(OutMinBuffer,float2(xDefaultMapValues.z, yDefaultMapValues.z), i.x);
	float2 OutMax = sbLoad(OutMaxBuffer,float2(xDefaultMapValues.w, yDefaultMapValues.w), i.x);
	
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



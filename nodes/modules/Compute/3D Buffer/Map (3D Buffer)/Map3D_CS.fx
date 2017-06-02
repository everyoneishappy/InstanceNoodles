#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef MAP_FXH
#include <packs\happy.fxh\map.fxh>
#endif

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

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float3 Value = sbLoad(ValueBuffer,0, i.x);
	float3 InMin = sbLoad(InMinBuffer, inMinValues, i.x);
	float3 InMax = sbLoad(InMaxBuffer,inMaxValues, i.x);
	float3 OutMin = sbLoad(OutMinBuffer,outMinValues, i.x);
	float3 OutMax = sbLoad(OutMaxBuffer,outMaxValues, i.x);
	
	Output[i.x] = map( Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapClamp(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float3 Value = sbLoad(ValueBuffer,0, i.x);
	float3 InMin = sbLoad(InMinBuffer, inMinValues, i.x);
	float3 InMax = sbLoad(InMaxBuffer,inMaxValues, i.x);
	float3 OutMin = sbLoad(OutMinBuffer,outMinValues, i.x);
	float3 OutMax = sbLoad(OutMaxBuffer,outMaxValues, i.x);
	
	Output[i.x] = mapClamp( Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapWrap(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float3 Value = sbLoad(ValueBuffer,0, i.x);
	float3 InMin = sbLoad(InMinBuffer, inMinValues, i.x);
	float3 InMax = sbLoad(InMaxBuffer,inMaxValues, i.x);
	float3 OutMin = sbLoad(OutMinBuffer,outMinValues, i.x);
	float3 OutMax = sbLoad(OutMaxBuffer,outMaxValues, i.x);
	
	Output[i.x] = mapWrap( Value,  InMin,  InMax,  OutMin,  OutMax);
}

[numthreads(GROUPSIZE)]
void CS_MapMirror(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	
	float3 Value = sbLoad(ValueBuffer,0, i.x);
	float3 InMin = sbLoad(InMinBuffer, inMinValues, i.x);
	float3 InMax = sbLoad(InMaxBuffer,inMaxValues, i.x);
	float3 OutMin = sbLoad(OutMinBuffer,outMinValues, i.x);
	float3 OutMax = sbLoad(OutMaxBuffer,outMaxValues, i.x);
	
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

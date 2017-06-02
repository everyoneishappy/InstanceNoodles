#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef MAP_FXH
#include <packs\happy.fxh\map.fxh>
#endif

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

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Map(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	if (sbLoad(initializeBuffer, initializeDefault, i.x))
	{
		Output[i.x] = sbLoad(initialBuffer, initialDefault, i.x);
		return;
	}
	float Value = Output[i.x] + sbLoad(ValueBuffer, 0, i.x);
	float mapMin = sbLoad(minBuffer, minDefault, i.x);
	float mapMax = sbLoad(maxBuffer, maxDefault, i.x);

	Output[i.x] = map( Value,  mapMin,  mapMax,  mapMin,  mapMax);
}

[numthreads(GROUPSIZE)]
void CS_MapClamp(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	if (sbLoad(initializeBuffer, initializeDefault, i.x))
	{
		Output[i.x] = sbLoad(initialBuffer, initialDefault, i.x);
		return;
	}
	float Value = Output[i.x] + sbLoad(ValueBuffer, 0, i.x);
	float mapMin = sbLoad(minBuffer, minDefault, i.x);
	float mapMax = sbLoad(maxBuffer, maxDefault, i.x);

	Output[i.x] = mapClamp( Value,  mapMin,  mapMax,  mapMin,  mapMax);
}

[numthreads(GROUPSIZE)]
void CS_MapWrap(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	if (sbLoad(initializeBuffer, initializeDefault, i.x))
	{
		Output[i.x] = sbLoad(initialBuffer, initialDefault, i.x);
		return;
	}
	float Value = Output[i.x] + sbLoad(ValueBuffer, 0, i.x);
	float mapMin = sbLoad(minBuffer, minDefault, i.x);
	float mapMax = sbLoad(maxBuffer, maxDefault, i.x);

	Output[i.x] = mapWrap( Value,  mapMin,  mapMax,  mapMin,  mapMax);
}

[numthreads(GROUPSIZE)]
void CS_MapMirror(uint3 i : SV_DispatchThreadID)
{
	if (i.x >= threadCount) { return; }
	if (sbLoad(initializeBuffer, initializeDefault, i.x))
	{
		Output[i.x] = sbLoad(initialBuffer, initialDefault, i.x);
		return;
	}
	float Value = Output[i.x] + sbLoad(ValueBuffer, 0, i.x);
	float mapMin = sbLoad(minBuffer, minDefault, i.x);
	float mapMax = sbLoad(maxBuffer, maxDefault, i.x);

	Output[i.x] = mapMirror( Value,  mapMin,  mapMax,  mapMin,  mapMax);
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



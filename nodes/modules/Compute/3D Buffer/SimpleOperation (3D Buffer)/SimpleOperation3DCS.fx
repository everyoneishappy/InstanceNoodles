#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float3> vectorA, vectorB;
float3 DefaultA, DefaultB = 0;
RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;

uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Add(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float3 valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA + valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Subtract(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float3 valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA - valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Multiply(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float3 valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA * valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Divide(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float3 valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA / valueB;		
}

[numthreads(GROUPSIZE)]
void CS_Cross(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float3 valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float3 valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = cross(valueA, valueB);		
}


technique11 Add
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Add() ) );
	}
}

technique11 Subtract
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Subtract() ) );
	}
}

technique11 Multiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Multiply() ) );
	}
}

technique11 Divide
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Divide() ) );
	}
}

technique11 CrossMultiply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Cross() ) );
	}
}
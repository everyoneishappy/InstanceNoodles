#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

StructuredBuffer<float> vectorA, vectorB;
float DefaultA, DefaultB = 0;
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Add(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA + valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Subtract(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA - valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Multiply(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA * valueB;	
}

[numthreads(GROUPSIZE)]
void CS_Divide(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float valueA = sbLoad(vectorA, DefaultA, dtid.x);
	float valueB = sbLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA / valueB;		
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


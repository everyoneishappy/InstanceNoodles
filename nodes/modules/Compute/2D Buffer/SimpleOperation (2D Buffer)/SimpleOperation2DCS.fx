#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float2> vectorA, vectorB;
float2 DefaultA, DefaultB = 0;
RWStructuredBuffer<float2> RWValueBuffer : BACKBUFFER;




[numthreads(64,1,1)]
void CS_Add(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float2 valueA = bLoad(vectorA, DefaultA, dtid.x);
	float2 valueB = bLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA + valueB;	
}

[numthreads(64,1,1)]
void CS_Subtract(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float2 valueA = bLoad(vectorA, DefaultA, dtid.x);
	float2 valueB = bLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA - valueB;	
}

[numthreads(64,1,1)]
void CS_Multiply(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float2 valueA = bLoad(vectorA, DefaultA, dtid.x);
	float2 valueB = bLoad(vectorB, DefaultB, dtid.x);
	
	RWValueBuffer[dtid.x] = valueA * valueB;	
}

[numthreads(64,1,1)]
void CS_Divide(uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }

	float2 valueA = bLoad(vectorA, DefaultA, dtid.x);
	float2 valueB = bLoad(vectorB, DefaultB, dtid.x);
	
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


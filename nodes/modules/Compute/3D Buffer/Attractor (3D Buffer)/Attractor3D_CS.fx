#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float3> Output : BACKBUFFER;

StructuredBuffer<float3> posBuffer;

//ATTRACTORS:
//float4x4 attrForceT;
//Attractors Transform Buffer
StructuredBuffer<float4x4> attrForceT;
//Attractors Position Buffer
StructuredBuffer<float3> attrPos;
//Attractors Data Buffer (X = radius, Y = Strength Z = Power)
StructuredBuffer<float3> attrData;


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_AttractorsPostion( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float3 p = posBuffer[dtid.x % sbSize(posBuffer)];

	uint aCount,tCount,dCount;	
	aCount = sbSize(attrPos);
	tCount = sbSize(attrForceT);
	dCount = sbSize(attrData);
	
	float3 v = 0;
	
	for(uint i=0 ; i<aCount; i++)
	{
		//attrVec = p - attrBuffer[i];
		float3 attrVec = attrPos[i] - p;
		float attrRadius = attrData[i % dCount].x;
		float attrStrength = attrData[i % dCount].y;
		float attrPower = attrData[i % dCount].z;

		float attrForce = length(attrVec) / attrRadius;
		attrForce = 1 - attrForce;
		attrForce = saturate(attrForce);
		attrForce = pow(attrForce, attrPower);
		attrVec = attrVec * attrForce * attrStrength;
		//transform attraction vector:
		attrVec = mul(float4(attrVec,1), attrForceT[i % tCount]).xyz;
		v += attrVec;
		}

	Output[dtid.x] =  p+v;		
}

[numthreads(GROUPSIZE)]
void CS_AttractorsValue ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float3 p = posBuffer[dtid.x % sbSize(posBuffer)];

	uint aCount,tCount,dCount;	
	aCount = sbSize(attrPos);
	tCount = sbSize(attrForceT);
	dCount = sbSize(attrData);
	
	float3 v = 0;
	
	for(uint i=0 ; i<aCount; i++)
	{
		//attrVec = p - attrBuffer[i];
		float3 attrVec = attrPos[i] - p;
		float attrRadius = attrData[i % dCount].x;
		float attrStrength = attrData[i % dCount].y;
		float attrPower = attrData[i % dCount].z;

		float attrForce = length(attrVec) / attrRadius;
		attrForce = 1 - attrForce;
		attrForce = saturate(attrForce);
		attrForce = pow(attrForce, attrPower);
		attrVec = attrVec * attrForce * attrStrength;
		//transform attraction vector:
		attrVec = mul(float4(attrVec,1), attrForceT[i % tCount]).xyz;
		v += attrVec;
		}

	Output[dtid.x] = v;	
	
}

technique11 AttractorsPostion
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_AttractorsPostion() ) );
	}
}

technique11 AttractorsVector
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_AttractorsValue() ) );
	}
}

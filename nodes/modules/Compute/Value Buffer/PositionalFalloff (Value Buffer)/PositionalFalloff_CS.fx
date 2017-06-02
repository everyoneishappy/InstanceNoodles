#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float> Output : BACKBUFFER;
StructuredBuffer<float3> posBuffer;

float4x4 inverseMatrix;
float sphereR = 1;
float3 boxSize = 1;
float falloffDist = 6;

float sdSphere( float3 p, float s )
{
  return length(p)-s;
}

float sdBox( float3 p, float3 b )
{
  float3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdPlane( float3 p, float4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}
   

float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
	{
		float range = InMax - InMin;
		float normalized = (Input - InMin) / range;	
	    float output = OutMin + normalized * (OutMax - OutMin);
		float minV = min(OutMin,OutMax);
		float maxV = max(OutMin, OutMax);
	   	output = min(max(output, minV), maxV);
		return output ;
	}


uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif
[numthreads(GROUPSIZE)]
void CS_SphereFalloff( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }
	
	float3 pos = posBuffer[i.x % sbSize(posBuffer)];
	pos = mul(float4(pos,1), inverseMatrix).xyz;
	
	float dist = -sdSphere(pos, sphereR); //positve values inside shape
	dist *= max(0, sign(dist)); //negitive values = 0
	
	float falloff = map(dist,0,falloffDist,0,1);
	
	Output[i.x] = falloff;
}

[numthreads(GROUPSIZE)]
void CS_BoxFalloff( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }
	
	float3 pos = posBuffer[i.x % sbSize(posBuffer)];
	pos = mul(float4(pos,1), inverseMatrix).xyz;
	
	float dist = -sdBox (pos, boxSize); //positve values inside shape
	dist *= max(0, sign(dist)); //negitive values = 0
	
	float falloff = map(dist,0,falloffDist,0,1);
	
	Output[i.x] = falloff;
}

[numthreads(GROUPSIZE)]
void CS_LinearFalloff( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }

	float3 pos = posBuffer[i.x % sbSize(posBuffer)];
	pos = mul(float4(pos,1), inverseMatrix).xyz;
	
	float dist = -sdPlane (pos, float4(0,1,0,1)); //positve values inside shape
	dist *= max(0, sign(dist)); //negitive values = 0
	
	float falloff = map(dist,0,falloffDist,0,1);
	
	Output[i.x] = falloff;
}


technique11 Sphere
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_SphereFalloff() ) );
	}
}

technique11 Box
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_BoxFalloff() ) );
	}
}

technique11 Linear
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_LinearFalloff() ) );
	}
}
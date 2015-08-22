
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
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


[numthreads(64, 1, 1)]
void CS_SphereFalloff( uint3 i : SV_DispatchThreadID)
{ 
	uint posCount,dummy;	
	posBuffer.GetDimensions(posCount,dummy);
	float3 pos = posBuffer[i.x % posCount];
	
	pos = mul(float4(pos,1), inverseMatrix);
	
	float dist = -sdSphere(pos, sphereR); //positve values inside shape
	
	dist *= max(0, sign(dist)); //negitive values = 0
	
	float falloff = map(dist,0,falloffDist,0,1);
	
	Output[i.x] = falloff;
}

[numthreads(64, 1, 1)]
void CS_BoxFalloff( uint3 i : SV_DispatchThreadID)
{ 
	uint posCount,dummy;	
	posBuffer.GetDimensions(posCount,dummy);
	float3 pos = posBuffer[i.x % posCount];
	
	pos = mul(float4(pos,1), inverseMatrix);
	
	float dist = -sdBox (pos, boxSize); //positve values inside shape
	
	dist *= max(0, sign(dist)); //negitive values = 0
	
	float falloff = map(dist,0,falloffDist,0,1);
	
	Output[i.x] = falloff;
}

[numthreads(64, 1, 1)]
void CS_LinearFalloff( uint3 i : SV_DispatchThreadID)
{ 
	uint posCount,dummy;	
	posBuffer.GetDimensions(posCount,dummy);
	float3 pos = posBuffer[i.x % posCount];
	
	pos = mul(float4(pos,1), inverseMatrix);
	
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
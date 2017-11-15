float threadCount; 

#include "noiseSimplex.fxh"

float defaultSpeed = 0.001;
StructuredBuffer<float> bSpeed;
float freq;

float3 offset;
float eps = 0.2;

bool reset = 0;
StructuredBuffer<float> resetBuffer;

StructuredBuffer<float3> XYZbuffer;
RWStructuredBuffer<float3> Output : BACKBUFFER;


float3 ComputeCurl (float x, float y, float z)
{
	float n1, n2, a, b;
	float3 curl;
	
	float x1, x2 , y1, y2, z1, z2;
	
	x1 = snoise(float3(x + eps, y, z));
	x2 = snoise(float3(x - eps, y, z));
	y1 = snoise(float3(x, y + eps, z));
	y2 = snoise(float3(x, y - eps, z));
	z1 = snoise(float3(x, y, z + eps));
	z2 = snoise(float3(x, y, z - eps));
	
	
	a = (y1 - y2) / (2* eps);
	b = (z1 - z2) / (2* eps);
	curl.x = a - b;
	
	a = (z1 - z2) / (2* eps);
	b = (x1 - x2) / (2* eps);
	curl.y = a - b;
		
	a = (x1 - x2) / (2* eps);
	b = (z1 - z1) / (2* eps);
	curl.z = a - b;
	
	return curl;
	
}

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CS_CurlPos( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; } 
	// get buffer count
	uint rCount,dummy;	
	resetBuffer.GetDimensions(rCount,dummy);
	
	if (reset || resetBuffer[DTid.x % rCount]) Output[DTid.x] = XYZbuffer[DTid.x];
	float3 p = Output[DTid.x];
	float3 v = (p + offset) * freq;
	
	// get buffer count
	uint sCount;	
	bSpeed.GetDimensions(sCount,dummy);
	float speed = defaultSpeed;
	if(sCount>0) speed = bSpeed[DTid.x % sCount];
	speed *= 0.01;
	
	
	p += ComputeCurl(v.x,v.y,v.z) * speed;
	Output[DTid.x] = p;	
	
}

[numthreads(64, 1, 1)]
void CS_CurlVel( uint3 DTid : SV_DispatchThreadID )
{
	if (DTid.x >= threadCount) { return; } 
	if (reset) Output[DTid.x] = XYZbuffer[DTid.x];
	float3 p = Output[DTid.x];
	float3 v = (p + offset) * freq;
	
	// get buffer count
	uint sCount,dummy;	
	bSpeed.GetDimensions(sCount,dummy);
	float speed = defaultSpeed;
	if(sCount>0) speed = bSpeed[DTid.x % sCount];
	speed *= 0.01;
	
	Output[DTid.x] = ComputeCurl(v.x,v.y,v.z) * speed;
	
}


//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 CurlPos
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_CurlPos() ) );
	}
}

technique11 CurlVectors
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_CurlVel() ) );
	}
}

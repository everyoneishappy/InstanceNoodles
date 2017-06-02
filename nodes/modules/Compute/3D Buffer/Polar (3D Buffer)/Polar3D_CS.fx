#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#define TWOPI 6.28318531
#define PI 3.14159265

RWStructuredBuffer<float3> output : BACKBUFFER;
StructuredBuffer<float3> inputBuffer;

float3 Cart2Polar(float3 v)
{
	float3 result;
	float r;
	//r = length(v);
	r = v.x * v.x + v.y * v.y + v.z * v.z;
	
	if (r > 0)
	{
		r = sqrt(r);
		float p, y;
		p = asin(v.y/r) / TWOPI;
		y = 0;
		if (v.z != 0) y = atan2(-v.x, -v.z);
		else if (v.x > 0) y = -PI / 2;
        else y = PI / 2;
		y /=  TWOPI;
		result = float3(p,y,r);		
	}
	else
	{
		result = 0;
	}
	return result;
};

float3 Polar2Cart(float3 v)
{
	
	v.xy *= TWOPI;
	float cosp = -v.z * cos(v.x);
	float3 result = float3(cosp * sin(v.y), v.z * sin(v.x),cosp * cos(v.y));
	return result;
};


uint threadCount;

#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Polar ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	float3 v = inputBuffer[dtid.x % sbSize(inputBuffer)];
	output[dtid.x] = Cart2Polar(v);
}


[numthreads(GROUPSIZE)]
void CS_Cart ( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	float3 v = inputBuffer[dtid.x % sbSize(inputBuffer)];
	output[dtid.x] = Polar2Cart(v);
}

technique11 CartToPolar
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Polar() ) );
	}
}

technique11 PolarToCart
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Cart() ) );
	}
}














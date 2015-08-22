#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> xb,yb,zb,wb;
float x,y,z,w = 0;



RWStructuredBuffer<float4> RWValueBuffer : BACKBUFFER;

// color conversion by Ian Taylor (from http://www.chilliant.com/rgb2hsv.html)
float3 HUEtoRGB(in float H){
	H=frac(H);
	float R = abs(H * 6 - 3) - 1;
	float G = 2 - abs(H * 6 - 2);
	float B = 2 - abs(H * 6 - 4);
	return saturate(float3(R,G,B));
}

float3 HSLtoRGB(in float3 HSL)
{
	float3 RGB = HUEtoRGB(HSL.x);
	float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
	return (RGB - 0.5) * C + HSL.z;
}

[numthreads(64,1,1)]
void CS_HSL(uint3 dtid : SV_DispatchThreadID)
{
	float h = bLoad(xb, x, dtid.x);
	float s = bLoad(yb, y, dtid.x);
	float l = bLoad(zb, z, dtid.x);
	float a = bLoad(wb, w, dtid.x);
	
	float4 col = float4(HSLtoRGB(float3(h,s,l)),a);
	
	RWValueBuffer[dtid.x] = col;
	
}




technique11 HSL
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_HSL() ) );
	}
}


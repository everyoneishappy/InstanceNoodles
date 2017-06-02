#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef COLOR_FXH
#include <packs\happy.fxh\color.fxh>
#endif

StructuredBuffer<float> xb,yb,zb,wb;
float x,y,z,w = 0;



RWStructuredBuffer<float4> RWValueBuffer : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_HSL(uint3 dtid : SV_DispatchThreadID)
{
	float h = sbLoad(xb, x, dtid.x);
	float s = sbLoad(yb, y, dtid.x);
	float l = sbLoad(zb, z, dtid.x);
	float a = sbLoad(wb, w, dtid.x);
	
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


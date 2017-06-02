#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif


RWStructuredBuffer<float4> output : BACKBUFFER;


float4 dv1, dv2 = 0;
StructuredBuffer<float4> bv1, bv2;
StructuredBuffer<int> bi1, bi2;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSzip( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	int i1 = bi1[dtid.x];
	int i2 = bi2[dtid.x];
	float4 v1 = sbLoad(bv1, dv1, i1);
	float4 v2 = sbLoad(bv2, dv2, i2);


	output[dtid.x] = (i2 < 0) ?  v1 : v2;

}



technique11 Zip
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSzip() ) );
	}
}








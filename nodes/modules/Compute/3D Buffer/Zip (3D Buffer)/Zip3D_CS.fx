#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> output : BACKBUFFER;


float3 dv1, dv2 = 0;
StructuredBuffer<float3> bv1, bv2;
StructuredBuffer<int> bi1, bi2;




[numthreads(64, 1, 1)]
void CSzip( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	int i1 = bi1[dtid.x];
	int i2 = bi2[dtid.x];
	float3 v1 = bLoad(bv1, dv1, i1);
	float3 v2 = bLoad(bv2, dv2, i2);


	output[dtid.x] = (i2 < 0) ?  v1 : v2;

}



technique11 Zip
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSzip() ) );
	}
}








#include "..\..\..\Common\InstanceNoodles.fxh"


RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
float3 Pos;
StructuredBuffer<float3> bPos;




[numthreads(64, 1, 1)]
void CS( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; } 
	
	float4x4 Mat ={ 1, 0, 0,  0, 
 					0, 1, 0,  0, 
 					0, 0, 1,  0, 
  					0, 0, 0,  1 };

	float4x4 tMat = bLoad(bTransform, Mat, dtid.x);
	float3 pos = bLoad(bPos, Pos, dtid.x);
	
	Mat._41 += pos.x;
	Mat._42 += pos.y;
	Mat._43 += pos.z;
	output[dtid.x] = mul( Mat,tMat);
	
	
	
}



technique11 Translate
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








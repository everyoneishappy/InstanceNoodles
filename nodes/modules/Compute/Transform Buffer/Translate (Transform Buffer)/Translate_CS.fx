#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float> xb,yb,zb;
float x,y,z = 0;



[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; } 

	float4x4 mat ={ 1, 0, 0,  0,
 					0, 1, 0,  0, 
 					0, 0, 1,  0, 
  					0, 0, 0,  1 };
	float4x4 tMat = bLoad(bTransform, mat, dtid.x);
	float3 xyz;
	xyz.x = bLoad(xb,x,dtid.x);
	xyz.y = bLoad(yb,y,dtid.x);
	xyz.z = bLoad(zb,z,dtid.x);
	

	mat._41 += xyz.x;
	mat._42 += xyz.y;
	mat._43 += xyz.z;
	output[dtid.x] = mul( mat,tMat);
	
	
	
}



technique11 FeedbackTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








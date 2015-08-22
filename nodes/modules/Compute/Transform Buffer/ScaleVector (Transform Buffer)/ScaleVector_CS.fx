#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float3> bScale;




[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
		
	// set default value for buffer if empty
	float4x4 mat ={ 1, 0, 0,  0, 
 				0, 1, 0,  0, 
 				0, 0, 1,  0, 
  				0, 0, 0,  1 };
	mat = bLoad(bTransform, mat, dtid.x);
	
	float3 scale = bLoad(bScale, 1, dtid.x); 
	
	float4x4 scaleM = {scale.x,0,0,0,  0,scale.y,0,0,  0,0,scale.z,0, 0,0,0,1} ;
	
	output[dtid.x] = mul(scaleM,mat);
	
	
	
}



technique11 Scale
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








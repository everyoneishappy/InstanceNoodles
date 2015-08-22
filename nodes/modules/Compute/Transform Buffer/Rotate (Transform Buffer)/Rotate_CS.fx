#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
float3 dRotate = 0;
StructuredBuffer<float3> bRotate;

//Rotate Function 
float4x4 Rotmatrix(float yaw,float pitch,float roll)
{
	float3 z=float3(yaw,pitch,roll)*acos(-1)*2;float3 x=cos(z),y=sin(z);
	return float4x4(x.y*x.z+y.x*y.y*y.z,-x.x*y.z,y.x*x.y*y.z-y.y*x.z,0,x.y*y.z-y.x*y.y*x.z,x.x*x.z,-y.y*y.z-y.x*x.y*x.z,0,x.x*y.y,y.x,x.x*x.y,0,0,0,0,1);
}


[numthreads(64, 1, 1)]
void CS( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	// set default value for buffer if empty
	float4x4 dt ={ 1, 0, 0,  0, 
 				0, 1, 0,  0, 
 				0, 0, 1,  0, 
  				0, 0, 0,  1 };
	
	float4x4 mat = bLoad(bTransform, dt, dtid.x);
	float3 rotate = bLoad(bRotate, dRotate, dtid.x);
	float pitch = rotate.y;
	float yaw = rotate.x;
	float roll = rotate.z;
	float4x4 rMat = Rotmatrix(yaw,pitch,roll);
	output[dtid.x] = mul (rMat, mat);
	
	
	
}



technique11 Rotate
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}








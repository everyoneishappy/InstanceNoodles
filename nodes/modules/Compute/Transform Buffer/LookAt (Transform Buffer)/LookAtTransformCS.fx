#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float3> bDir;
float3 dirValue=0;
float3 upvector = float3(0,1,0);

float3x3 lookat(float3 dir,float3 up=float3(0,1,0))
{
	float3 z=normalize(dir);float3 x=normalize(cross(up,z));float3 y=normalize(cross(z,x));return float3x3(x,y,z);
}

[numthreads(64, 1, 1)]
void CSlookat( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; } 

	float4x4 transformM = bTransform[dtid.x % bSize(bTransform)];
	


	float3 dir = bLoad(bDir, dirValue, dtid.x);
	dir = normalize(dir);
	float3x3 lookatM = lookat(dir,upvector);
	
	float4x4 lookatMat ={lookatM._11,  lookatM._12,  lookatM._13,  0, 
 						lookatM._21,  lookatM._22,  lookatM._23,  0, 
 						lookatM._31,  lookatM._32,  lookatM._33,  0, 
  						0,    0,    0,  1 };
	
	output[dtid.x] = mul(lookatMat, transformM);
}



technique11 LookAtTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSlookat() ) );
	}
}








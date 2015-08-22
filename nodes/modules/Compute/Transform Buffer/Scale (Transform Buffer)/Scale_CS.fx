#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> transform;
StructuredBuffer<float> xb,yb,zb;
float x,y,z = 1;




[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	uint mCount, xCount, yCount, zCount,dummy;	
	transform.GetDimensions(mCount,dummy),xb.GetDimensions(xCount,dummy),yb.GetDimensions(yCount,dummy),zb.GetDimensions(zCount,dummy);
	

	float4x4 mat = bLoad(transform, float4x4 (1, 0, 0, 0, 0, 1, 0,  0, 0, 0, 1, 0, 0, 0, 0, 1 ), dtid.x);
	
	float3 scale = float3 (x,y,z);
	if(xCount>0) scale.x = xb[dtid.x % xCount];
	if(yCount>0) scale.y = yb[dtid.x % yCount];
	if(zCount>0) scale.z = zb[dtid.x % zCount];
	
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








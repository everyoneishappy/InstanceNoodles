#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif

RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> bTransform;
StructuredBuffer<float> xb,yb,zb;
float x,y,z = 1;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	uint mCount, xCount, yCount, zCount,dummy;	
	bTransform.GetDimensions(mCount,dummy),xb.GetDimensions(xCount,dummy),yb.GetDimensions(yCount,dummy),zb.GetDimensions(zCount,dummy);
	
	float3 scale = float3 (x,y,z);
	if(xCount>0) scale.x = xb[dtid.x % xCount];
	if(yCount>0) scale.y = yb[dtid.x % yCount];
	if(zCount>0) scale.z = zb[dtid.x % zCount];
	
	float4x4 tMat = sbLoad(bTransform, identity4x4(), dtid.x);
	output[dtid.x] = mul(scaleM(scale, identity4x4()), tMat);
	
	
	
}



technique11 Scale
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








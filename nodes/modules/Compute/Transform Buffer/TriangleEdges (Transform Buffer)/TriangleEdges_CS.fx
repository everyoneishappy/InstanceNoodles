#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif
RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float3> bPos;
float shrinkDefualt;
StructuredBuffer<float> shrinkBuffer;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS(uint3 tid : SV_DispatchThreadID)
{
	if (tid.x >= threadCount) return;
	
	float3 p[3];
	for (uint i=0; i<3; i++)
	{
		p[i] = bPos[tid.x * 3 + i];
	}
	

	//Compute face center
	float3 faceCenter = (p[0] + p[1] + p[2]) / 3.0;
	
	//Compute face normal
	float3 n = normalize(cross(p[1] - p[0], p[2] - p[1]));
	
	// shrink the triangle
	float shirnk = saturate(sbLoad(shrinkBuffer, shrinkDefualt, tid.x));
	p[0] = lerp (p[0], faceCenter, shirnk);
	p[1] = lerp (p[1], faceCenter, shirnk);
	p[2] = lerp (p[2], faceCenter, shirnk);
	
	for(uint j=0;j<3;j++)
	{
		float3 p1 = p[j];
		float3 p2 =  p[(j + 1) % 3];
		float3 edgeCenter = (p1 + p2) / 2.0;
		float3 dir = -cross(n, p1 - p2);
		float4x4 lkt=lookat4x4(dir, n);
		float4x4 m = identity4x4();

		
		float l = length(p1-p2);
		m._11 *= l;  
		m._21 *= l; 
		m._31 *= l; 
		m._41 *= l; 
		
		m = mul(m,  lkt);
		
		
		m._41 = edgeCenter.x;
		m._42 = edgeCenter.y;
		m._43 = edgeCenter.z;

		output[tid.x * 3 + j] = m;
	}
	



}

technique11 Apply
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}





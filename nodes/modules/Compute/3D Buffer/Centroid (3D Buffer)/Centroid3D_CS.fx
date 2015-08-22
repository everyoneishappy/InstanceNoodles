#include "..\..\..\Common\InstanceNoodles.fxh"

RWStructuredBuffer<float3> output : BACKBUFFER;
StructuredBuffer<float3> posBuffer <string uiname="Position 3D Buffer";>;



[numthreads(64, 1, 1)]
void CSpos( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x > threadCount) { return; }
	
	float3 avgPoint = 0;
	for(uint i=0; i<3; i++) avgPoint += ( posBuffer[(dtid.x*3 + i) % bSize(posBuffer)])/3;
	
	output[dtid.x] = avgPoint;
}

[numthreads(64, 1, 1)]
void CSNorm( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x > threadCount) { return; }
	
	float3 Normals[3];
	for(uint i=0; i<3; i++) Normals[i] = posBuffer[(dtid.x*3 + i) % bSize(posBuffer)];
		//Get triangle face direction
	float3 f1 = Normals[1] - Normals[0];
    float3 f2 = Normals[2] - Normals[0];
    
	//Compute flat normal
	float3 norm = normalize(cross(f1, f2));
	
	output[dtid.x] = norm;
}


technique11 Postion
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSpos() ) );
	}
}


technique11 Normals
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSNorm() ) );
	}
}






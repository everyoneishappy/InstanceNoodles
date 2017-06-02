// Marching Cubes technique is grabbed from
// https://github.com/kristofe/UnityGPUMarchingCubes

struct Triangle
{
	float3 TP[3];
	float3 TN[3];
	float3 TD;
};

AppendStructuredBuffer<Triangle> Outbuf : BACKBUFFER;
Texture3D _dataFieldTex;
float _dataSize = 64;
float _isoLevel = 0.5;

SamplerState s0
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
	AddressW = Clamp;
};

// somebody tell me what's the point of this???

float SampleData( float3 p)
{
	return _dataFieldTex.SampleLevel(s0,p,0).r;	
}

#include "CubeMarchConsts.fxh"

struct csin
{
	uint3 DTID : SV_DispatchThreadID;
	uint3 GTID : SV_GroupThreadID;
	uint3 GID : SV_GroupID;
};

void main(csin input)
{

	float3 SPos = input.DTID/_dataSize;
	const float halfSize = 0.5/_dataSize; 
	const float3 cubeVerts[8] =
	{
		//front face
		float3(-halfSize, -halfSize, -halfSize),
		float3(-halfSize,  halfSize, -halfSize),
		float3( halfSize,  halfSize, -halfSize),
		float3( halfSize, -halfSize, -halfSize),
		//bac0
		float3(-halfSize, -halfSize,  halfSize),
		float3(-halfSize,  halfSize,  halfSize),
		float3( halfSize,  halfSize,  halfSize),
		float3( halfSize, -halfSize,  halfSize)
	};

	//float3 offset = float4(0.5,0.5,0.5);//Move cube pos from 0-1 to -0.5-0.5
	//float3 offset = float3(0.0,0.0,0.0);
	float3 offset = halfSize;
	const float weights[8] =
	{
		SampleData(SPos + cubeVerts[0] + offset),
		SampleData(SPos + cubeVerts[1] + offset),
		SampleData(SPos + cubeVerts[2] + offset),
		SampleData(SPos + cubeVerts[3] + offset),
		SampleData(SPos + cubeVerts[4] + offset),
		SampleData(SPos + cubeVerts[5] + offset),
		SampleData(SPos + cubeVerts[6] + offset),
		SampleData(SPos + cubeVerts[7] + offset)
	};

	int cubeIndex = 
	(weights[7] < _isoLevel) * 128 + 
	(weights[6] < _isoLevel) * 64 +
	(weights[5] < _isoLevel) * 32 +
	(weights[4] < _isoLevel) * 16 +
	(weights[3] < _isoLevel) * 8 +
	(weights[2] < _isoLevel) * 4 +
	(weights[1] < _isoLevel) * 2 +
	(weights[0] < _isoLevel) * 1;

	Triangle Tri;
	for( int i = 0; i < 5; i++ )
	{
		int4 vertlistIndices = edge_connect_list[cubeIndex * 5 + i];
		if(vertlistIndices.x != -1)
		{	
			int va = edge_to_verts[vertlistIndices.x].x;
			int vb = edge_to_verts[vertlistIndices.x].y;
			float amount = (_isoLevel - weights[va]) / (weights[vb] - weights[va]);
			Tri.TD.x = amount;
			float3 worldPos = lerp( SPos + cubeVerts[va],  SPos + cubeVerts[vb], amount);
			float3 texA = worldPos+offset;
			float3 pA = worldPos;

			va = edge_to_verts[vertlistIndices.y].x;
			vb = edge_to_verts[vertlistIndices.y].y;
			amount = (_isoLevel - weights[va]) / (weights[vb] - weights[va]);
			Tri.TD.y = amount;
			worldPos = lerp( SPos + cubeVerts[va],  SPos + cubeVerts[vb], amount);
			float3 texB = worldPos+offset;
			float3 pB = worldPos;

			va = edge_to_verts[vertlistIndices.z].x;
			vb = edge_to_verts[vertlistIndices.z].y;
			amount = (_isoLevel - weights[va]) / (weights[vb] - weights[va]);
			Tri.TD.z = amount;
			worldPos = lerp( SPos + cubeVerts[va],  SPos + cubeVerts[vb], amount);
			float3 texC = worldPos+offset;
			float3 pC = worldPos;

			float3 r = pA - pC;
			float3 f = pA - pB;
			float3 normal = normalize(cross(f,r));

			Tri.TP[0] = pA;
			Tri.TN[0] = normal;

			Tri.TN[1] = normal;
			Tri.TP[1] = pC;

			Tri.TP[2] = pB;
			Tri.TN[2] = normal;
			Outbuf.Append(Tri);
		}
	}
}

[numthreads(8, 8, 8)]
void CS(csin input) { main(input); }
technique11 CS1 { pass P0{SetComputeShader( CompileShader( cs_5_0, CS() ) );} }
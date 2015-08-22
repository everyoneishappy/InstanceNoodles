#include "..\..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float4x4> transformBuffer;

RWStructuredBuffer<float3> RWValueBuffer : BACKBUFFER;


[numthreads(64,1,1)]
void CS_VectorJoin(uint3 i : SV_DispatchThreadID)
{

	
	// set default value for buffer if empty
	float4x4 mat ={ 1, 0, 0,  0, 
 				0, 1, 0,  0, 
 				0, 0, 1,  0, 
  				0, 0, 0,  1 };
	mat = bLoad(transformBuffer, mat, i.x);
	
	float3 pos = float3(mat._41, mat._42, mat._43);

	RWValueBuffer[i.x] = pos;
	
}




technique11 GetPos
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_VectorJoin() ) );
	}
}


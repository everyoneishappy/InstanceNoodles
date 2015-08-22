
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
int threadCount;
RWStructuredBuffer<float> output : BACKBUFFER;

StructuredBuffer<float3> pos;



[numthreads(64, 1, 1)]
void CSpos( uint3 i : SV_DispatchThreadID)
{ 
	if (i.x >= threadCount) { return; }
	
	float3 posA = pos[i.x * 3];
	float3 posB = pos[i.x * 3 + 1];
	float3 posC = pos[i.x * 3 + 2];
	
	//Get triangle face direction
	float3 f1 = posB - posA;
    float3 f2 = posC - posA;
    
	//Compute flat normal
	float3 norm = cross(f1, f2);
	
	//Cross product depends on area
	float v = dot(norm,norm);
	
	output[i.x] = v;
}



technique11 TriangleArea
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSpos() ) );
	}
}








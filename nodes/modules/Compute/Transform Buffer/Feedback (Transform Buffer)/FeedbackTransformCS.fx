
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float4x4> output : BACKBUFFER;

StructuredBuffer<float4x4> transform;
//float4x4 feedbackTransform;
StructuredBuffer<float4x4> feedbackTransform; 

int iterations = 3;

[numthreads(64, 1, 1)]
void CSft( uint3 dtid : SV_DispatchThreadID)
{ 
	
	uint ftCount,dummy;
	feedbackTransform.GetDimensions(ftCount,dummy);
	//uint ftID = dtid.x % ftCount;
	uint outID = dtid.x * (iterations +1);
	//output[outID] = mul(feedbackTransform, transform[dtid.x]);
	output[outID] = transform[dtid.x];
	
	for( uint i = 0;i < iterations; i++ )
	{
  	
		output[outID+i+1] = mul(feedbackTransform[(dtid.x * iterations + i) % ftCount], output[outID+i]);
		
		
	}
	
	
}



technique11 FeedbackTransform
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSft() ) );
	}
}








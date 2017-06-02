struct Oscillator
{	
float CurrentPos;
float PreviousPos;	
float CurrentVel;
float PreviousVel;	
};

StructuredBuffer<Oscillator> OscillatorIn;
RWStructuredBuffer<float> Output : BACKBUFFER;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif



[numthreads(GROUPSIZE)]
void CSpos( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x > threadCount) { return; }
	Output[dtid.x] = OscillatorIn[dtid.x].CurrentPos;
}




technique11 Read
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSpos() ) );
	}
}






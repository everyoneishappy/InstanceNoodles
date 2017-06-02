#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

float FrequencyDefualt=1;
float PhaseDefault=0;
float OffsetDefault=0;
float AmplitudeDefault=1;
StructuredBuffer<float> FrequencyBuffer, PhaseBuffer, OffsetBuffer, AmplitudeBuffer;

uint threadCount;

StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;


#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_Linear (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = sbLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = sbLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = sbLoad(OffsetBuffer, OffsetDefault, bin);
	float Amplitude = sbLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave = frac((id*Frequency*254./255.+Phase))-.5; 
	wave = wave * Amplitude + Offset;
	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(GROUPSIZE)]
void CS_Inverse (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = sbLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = sbLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = sbLoad(OffsetBuffer, OffsetDefault, bin);
	float Amplitude = sbLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave = 1-frac((id*Frequency*254./255.+Phase));
	wave -= .5;
	wave = wave * Amplitude + Offset;
	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(GROUPSIZE)]
void CS_Triangle (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = sbLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = sbLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = sbLoad(OffsetBuffer, OffsetDefault, bin);
	float Amplitude = sbLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave=1-2*abs(frac((id)*Frequency+Phase)-.5); //bit of extra jiggling to copy native node behaviour
	wave -= .5;
   	wave = wave * Amplitude + Offset;

	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(GROUPSIZE)]
void CS_Sine (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = sbLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = sbLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = sbLoad(OffsetBuffer, OffsetDefault, bin);
	float Amplitude = sbLoad(AmplitudeBuffer, AmplitudeDefault, bin);
	
    float wave = .5+.5*cos((id*Frequency+Phase)*acos(-1)*2);
	wave -= .5;
	wave = wave * Amplitude + Offset;
    RWValueBuffer[dtid.x] = wave;

}

[numthreads(GROUPSIZE)]
void CS_Square (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = sbLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = sbLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = sbLoad(OffsetBuffer, OffsetDefault, bin);
	float Amplitude = sbLoad(AmplitudeBuffer, PhaseDefault, bin);
	
    float wave = step(-(frac((id*Frequency*254./255.+Phase))-.5),0);
	wave -= .5;
	wave = wave * Amplitude + Offset;
    RWValueBuffer[dtid.x] = wave;

}


technique11 LinearWave
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Linear () ) );
	}
}

technique11 InverseWave
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Inverse () ) );
	}
}

technique11 TriangleWave
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Triangle () ) );
	}
}


technique11 SineWave
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Sine () ) );
	}
}

technique11 SquareWave
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Square () ) );
	}
}



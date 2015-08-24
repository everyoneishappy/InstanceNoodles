#include "..\..\..\Common\InstanceNoodles.fxh"
RWStructuredBuffer<float> RWValueBuffer : BACKBUFFER;

float FrequencyDefualt=1;
float PhaseDefault=0;
float OffsetDefault=0;
float AmplitudeDefault=1;
StructuredBuffer<float> FrequencyBuffer, PhaseBuffer, OffsetBuffer, AmplitudeBuffer;



StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;


[numthreads(64,1,1)]
void CS_Linear (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = bLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = bLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = bLoad(OffsetBuffer, OffsetDefault, bin)-.5;
	float Amplitude = bLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave = frac((id*Frequency*254./255.+Phase));
	wave = wave * Amplitude + Offset;
	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(64,1,1)]
void CS_Inverse (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = bLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = bLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = bLoad(OffsetBuffer, OffsetDefault, bin)-.5;
	float Amplitude = bLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave = 1-frac((id*Frequency*254./255.+Phase));
	wave = wave * Amplitude + Offset;
	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(64,1,1)]
void CS_Triangle (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = bLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = bLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = bLoad(OffsetBuffer, OffsetDefault, bin)-.5;
	float Amplitude = bLoad(AmplitudeBuffer, PhaseDefault, bin);
	
	float wave=1-2*abs(frac((id)*Frequency+Phase)-.5);
   	wave = wave * Amplitude + Offset;

	
	RWValueBuffer[dtid.x] = wave ;
	
}

[numthreads(64,1,1)]
void CS_Sine (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = bLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = bLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = bLoad(OffsetBuffer, OffsetDefault, bin)-.5;
	float Amplitude = bLoad(AmplitudeBuffer, AmplitudeDefault, bin);
	
    float wave = .5+.5*cos((id*Frequency+Phase)*acos(-1)*2);
	wave = wave * Amplitude + Offset;
    RWValueBuffer[dtid.x] = wave;

}

[numthreads(64,1,1)]
void CS_Square (uint3 dtid : SV_DispatchThreadID)
{
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	float id = binAndOffsetsBuffer[dtid.x].y / binsize;
	
	float Frequency = bLoad(FrequencyBuffer, FrequencyDefualt, bin);
	float Phase = bLoad(PhaseBuffer, PhaseDefault, bin);
	float Offset = bLoad(OffsetBuffer, OffsetDefault, bin)-.5;
	float Amplitude = bLoad(AmplitudeBuffer, PhaseDefault, bin);
	
    float wave = step(-(frac((id*Frequency*254./255.+Phase))-.5),0);
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



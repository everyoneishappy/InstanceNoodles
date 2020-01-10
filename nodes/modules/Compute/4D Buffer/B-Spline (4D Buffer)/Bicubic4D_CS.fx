#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef SPLINE_FXH
#include <packs\happy.fxh\spline.fxh>
#endif
RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;

StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;


//int ControlPointPerSpline;


StructuredBuffer<float> PhaseB;
StructuredBuffer<float> controlPointBinsize;
StructuredBuffer<float> controlPointOffset;
StructuredBuffer<float4> controlPointB;

uint threadCount;
#ifndef GROUPSIZE 
#define GROUPSIZE 128,1,1
#endif

[numthreads(GROUPSIZE)]
void CS_BC( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	int pointID = binAndOffsetsBuffer[dtid.x].y;
	
	int ControlPointPerSpline = controlPointBinsize[bin % sbSize(controlPointBinsize)];
	
	int offset = controlPointOffset[bin % sbSize(controlPointOffset)];
	
	float phase = sbLoad(PhaseB, pointID / binsize, dtid.x);
	//float phase = bLoad(PhaseB, frac(pointID*254./255.), dtid.x);
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = sbSize(controlPointB);
	//Grab four control points around our coordinate
	float4 c1 = controlPointB[(clamp(range-1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float4 c2 = controlPointB[(clamp(range-0,startctrl,endctrl)+offset) % ctrlBufferSize];
	float4 c3 = controlPointB[(clamp(range+1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float4 c4 = controlPointB[(clamp(range+2,startctrl,endctrl)+offset) % ctrlBufferSize];

	float4 result = BSplineCubic(c1,c2,c3,c4,range);
	rwbuffer[dtid.x] = result;
}

[numthreads(GROUPSIZE)]
void CS_BC_Looped( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	uint pointID = binAndOffsetsBuffer[dtid.x].y;
	
	uint ControlPointPerSpline = controlPointBinsize[bin % sbSize(controlPointBinsize)];
	
	uint offset = controlPointOffset[bin % sbSize(controlPointOffset)];
	
	float phase = sbLoad(PhaseB, pointID / binsize, dtid.x);
	//float phase = bLoad(PhaseB, frac(pointID*254./255.), dtid.x);
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	range += ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = sbSize(controlPointB);
	//Grab four control points around our coordinate
	float4 c1 = controlPointB[(range-1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float4 c2 = controlPointB[(range) % ControlPointPerSpline +offset % ctrlBufferSize];
	float4 c3 = controlPointB[(range+1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float4 c4 = controlPointB[(range+2) % ControlPointPerSpline +offset % ctrlBufferSize];

	float4 result = BSplineCubic(c1,c2,c3,c4,range);
	rwbuffer[dtid.x] = result;
}

technique11 BiCubic
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_BC() ) );
	}
}

technique11 BiCubicLooped
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_BC_Looped() ) );
	}
}







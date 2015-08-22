#include "..\..\..\Common\InstanceNoodles.fxh"
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float3> rwbuffer : BACKBUFFER;

float3 BSplineCubic3(float3 p1, float3 p2, float3 p3, float3 p4, float range) 
{
    float mu = frac(range);
   	float3 a0 = p4 - p3*3 + p2*3 - p1;
   	float3 a1 = p3*3 - p2*6 + p1*3.;
	float3 a2 = p3*3 - p1*3;
   	float3 a3 = p3 + p2*4 + p1;
	
	return (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
}
StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;


//int ControlPointPerSpline;


StructuredBuffer<float> PhaseB;
StructuredBuffer<float> controlPointBinsize;
StructuredBuffer<float> controlPointOffset;
StructuredBuffer<float3> controlPointB;


[numthreads(64, 1, 1)]
void CS_BC( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	int pointID = binAndOffsetsBuffer[dtid.x].y;
	
	int ControlPointPerSpline = controlPointBinsize[bin % bSize(controlPointBinsize)];
	
	int offset = controlPointOffset[bin % bSize(controlPointOffset)];
	
	float phase = bLoad(PhaseB, pointID / binsize, dtid.x);
	//float phase = bLoad(PhaseB, frac(pointID*254./255.), dtid.x);
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = bSize(controlPointB);
	//Grab four control points around our coordinate
	float3 c1 = controlPointB[(clamp(range-1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c2 = controlPointB[(clamp(range-0,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c3 = controlPointB[(clamp(range+1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c4 = controlPointB[(clamp(range+2,startctrl,endctrl)+offset) % ctrlBufferSize];

	float3 result = BSplineCubic3(c1,c2,c3,c4,range);
	rwbuffer[dtid.x] = result;
}

[numthreads(64, 1, 1)]
void CS_BC_Looped( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	uint pointID = binAndOffsetsBuffer[dtid.x].y;
	
	uint ControlPointPerSpline = controlPointBinsize[bin % bSize(controlPointBinsize)];
	
	uint offset = controlPointOffset[bin % bSize(controlPointOffset)];
	
	float phase = bLoad(PhaseB, pointID / binsize, dtid.x);
	//float phase = bLoad(PhaseB, frac(pointID*254./255.), dtid.x);
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	range += ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = bSize(controlPointB);
	//Grab four control points around our coordinate
	float3 c1 = controlPointB[(range-1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c2 = controlPointB[(range) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c3 = controlPointB[(range+1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c4 = controlPointB[(range+2) % ControlPointPerSpline +offset % ctrlBufferSize];

	float3 result = BSplineCubic3(c1,c2,c3,c4,range);
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







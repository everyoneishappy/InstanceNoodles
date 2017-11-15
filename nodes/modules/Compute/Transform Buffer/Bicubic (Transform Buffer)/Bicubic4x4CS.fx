#ifndef SBUFFER_FXH
#include <packs\happy.fxh\sbuffer.fxh>
#endif

#ifndef SPLINE_FXH
#include <packs\happy.fxh\spline.fxh>
#endif

#ifndef TRANSFORM_FXH
#include <packs\happy.fxh\transform.fxh>
#endif

RWStructuredBuffer<float4x4> rwbuffer : BACKBUFFER;


float TwoPi : IMMUTABLE = 6.283185307179586476925286766559;

StructuredBuffer<float> twistBuffer;





StructuredBuffer<float> binsizeBuffer;
StructuredBuffer<float2> binAndOffsetsBuffer;


//int ControlPointPerSpline;


StructuredBuffer<float> PhaseB;
StructuredBuffer<float> controlPointBinsize;
StructuredBuffer<float> controlPointOffset;
StructuredBuffer<float3> controlPointB;


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
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = sbSize(controlPointB);
	//Grab four control points around our coordinate
	float3 c1 = controlPointB[(clamp(range-1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c2 = controlPointB[(clamp(range-0,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c3 = controlPointB[(clamp(range+1,startctrl,endctrl)+offset) % ctrlBufferSize];
	float3 c4 = controlPointB[(clamp(range+2,startctrl,endctrl)+offset) % ctrlBufferSize];
	SplinePosTan3 sp=(SplinePosTan3)0;
	sp = BSplineCubic3PT (c1,c2,c3,c4,range);
	
	float twist = twistBuffer [dtid.x % sbSize(twistBuffer)];
	float pitch = asin(sp.Tang.y)/TwoPi;
    float yaw = atan2(-sp.Tang.x, -sp.Tang.z)/ TwoPi;
	
	float4x4 transformM = rot4x4(pitch, yaw,twist);
	transformM._41 += sp.Pos.x;
	transformM._42 += sp.Pos.y;
	transformM._43 += sp.Pos.z;
	
	rwbuffer[dtid.x] = transformM;
}


[numthreads(GROUPSIZE)]
void CS_BC_Looped( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	int pointID = binAndOffsetsBuffer[dtid.x].y;
	int ControlPointPerSpline = controlPointBinsize[bin % sbSize(controlPointBinsize)];
	int offset = controlPointOffset[bin % sbSize(controlPointOffset)];
	float phase = sbLoad(PhaseB, pointID / binsize, dtid.x);
	phase = frac(phase);
	float range = phase * ControlPointPerSpline;
	range += ControlPointPerSpline;
	uint startctrl = 0;
	uint endctrl = ControlPointPerSpline - 1;
	uint ctrlBufferSize = sbSize(controlPointB);
	//Grab four control points around our coordinate
	float3 c1 = controlPointB[(range-1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c2 = controlPointB[(range) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c3 = controlPointB[(range+1) % ControlPointPerSpline +offset % ctrlBufferSize];
	float3 c4 = controlPointB[(range+2) % ControlPointPerSpline +offset % ctrlBufferSize];
	SplinePosTan3 sp=(SplinePosTan3)0;
	sp = BSplineCubic3PT (c1,c2,c3,c4,range);
	
	float twist = twistBuffer [dtid.x % sbSize(twistBuffer)];
	float pitch = asin(sp.Tang.y)/TwoPi;
    float yaw = atan2(-sp.Tang.x, -sp.Tang.z)/ TwoPi;
	
	float4x4 transformM = rot4x4(pitch, yaw,twist);
	transformM._41 += sp.Pos.x;
	transformM._42 += sp.Pos.y;
	transformM._43 += sp.Pos.z;
	
	rwbuffer[dtid.x] = transformM;
}
/*

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

*/
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






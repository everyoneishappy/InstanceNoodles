#include "..\..\..\Common\InstanceNoodles.fxh"
//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<float4x4> rwbuffer : BACKBUFFER;


float TwoPi : IMMUTABLE = 6.283185307179586476925286766559;

StructuredBuffer<float> twistBuffer;

float4x4 Vrotate(float rotX, float rotY, float rotZ)
  {
   rotX *= TwoPi;
   rotY *= TwoPi;
   rotZ *= TwoPi;
   float sx = sin(rotX);
   float cx = cos(rotX);
   float sy = sin(rotY);
   float cy = cos(rotY);
   float sz = sin(rotZ);
   float cz = cos(rotZ);

   return float4x4( cz*cy+sz*sx*sy, sz*cx, cz*-sy+sz*sx*cy, 0,
                   -sz*cy+cz*sx*sy, cz*cx, sz*sy+cz*sx*cy , 0,
                    cx * sy       ,-sx   , cx * cy        , 0,
                    0             , 0    , 0              , 1);
  }

struct SplinePosTan3
{
	float3 Pos;
	float3 Tang;
};

SplinePosTan3 BSplineCubic3PT(float3 p1, float3 p2, float3 p3, float3 p4, float range) 
{
	SplinePosTan3 Out = (SplinePosTan3)0;

    float mu = frac(range);
   	float3 a0 = p4 - p3*3 + p2*3 - p1;
   	float3 a1 = p3*3 - p2*6 + p1*3.;
	float3 a2 = p3*3 - p1*3;
   	float3 a3 = p3 + p2*4 + p1;
	
	Out.Pos = (a3+mu*(a2+mu*(a1+mu*a0)))/6.;
	Out.Tang = normalize((mu*(2*a0*mu+a1)+mu*(a0*mu+a1)+a2)/6.);
	return Out;
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
	SplinePosTan3 sp=(SplinePosTan3)0;
	sp = BSplineCubic3PT (c1,c2,c3,c4,range);
	
	float twist = twistBuffer [dtid.x % bSize(twistBuffer)];
	float pitch = asin(sp.Tang.y)/TwoPi;
    float yaw = atan2(-sp.Tang.x, -sp.Tang.z)/ TwoPi;
	
	float4x4 transformM = Vrotate(pitch, yaw,twist);
	transformM._41 += sp.Pos.x;
	transformM._42 += sp.Pos.y;
	transformM._43 += sp.Pos.z;
	
	rwbuffer[dtid.x] = transformM;
}

[numthreads(64, 1, 1)]
void CS_BC_Looped( uint3 dtid : SV_DispatchThreadID)
{ 
	if (dtid.x >= threadCount) { return; }
	
	float bin = binAndOffsetsBuffer[dtid.x].x;
	float binsize = binsizeBuffer[bin];
	int pointID = binAndOffsetsBuffer[dtid.x].y;
	int ControlPointPerSpline = controlPointBinsize[bin % bSize(controlPointBinsize)];
	int offset = controlPointOffset[bin % bSize(controlPointOffset)];
	float phase = bLoad(PhaseB, pointID / binsize, dtid.x);
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
	SplinePosTan3 sp=(SplinePosTan3)0;
	sp = BSplineCubic3PT (c1,c2,c3,c4,range);
	
	float twist = twistBuffer [dtid.x % bSize(twistBuffer)];
	float pitch = asin(sp.Tang.y)/TwoPi;
    float yaw = atan2(-sp.Tang.x, -sp.Tang.z)/ TwoPi;
	
	float4x4 transformM = Vrotate(pitch, yaw,twist);
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






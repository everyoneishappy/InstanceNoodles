#ifndef SPLINE_STRUCTS_H
#define SPLINE_STRUCTS_H


//2d Spline with tangents
struct SplinePosTan2
{
	float2 Pos;
	float2 Tang;
};

//3d spline with tangents
struct SplinePosTan3
{
	float3 Pos;
	float3 Tang;
};

#endif
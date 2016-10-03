
RWTexture3D<float> RWDistanceVolume : BACKBUFFER;
Texture3D<float> volA, volB;
float p1, p2;
// Shortcut for 45-degrees rotation
void pR45(inout float2 p) 
{
	p = (p + float2(p.y, -p.x))*sqrt(0.5);
}

float pMod1(inout float p, float size) 
{
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = abs((p + halfsize) % size) - halfsize;
	return c;
}


// simple operations
float U(float a, float b) {return min(a,b);}
float S(float a, float b) {return max(a,-b);}
float I(float a, float b) {return max(a,b);}

//////////////////////////////////////////////////////////////////////////
//  advanced operations
//	Based on hg_sdf by MERCURY (CC BY-NC 2016)  http://mercury.sexy/hg_sdf
//	HLSL port by everyoneishappy
//////////////////////////////////////////////////////////////////////////

float fOpUnionChamfer(float a, float b, float r) 
{
	return min(min(a, b), (a - r + b)*sqrt(0.5));
}

float fOpIntersectionChamfer(float a, float b, float r) 
{
	return max(max(a, b), (a + r + b)*sqrt(0.5));
}

float fOpDifferenceChamfer (float a, float b, float r) 
{
	return fOpIntersectionChamfer(a, -b, r);
}

float fOpUnionRound(float a, float b, float r) 
{
	float2 u = max(float2(r - a,r - b), 0);
	return max(r, min (a, b)) - length(u);
}

float fOpIntersectionRound(float a, float b, float r) 
{
	float2 u = max(float2(r + a,r + b), 0);
	return min(-r, max (a, b)) + length(u);
}

float fOpDifferenceRound (float a, float b, float r) 
{
	return fOpIntersectionRound(a, -b, r);
}

float fOpUnionColumns(float a, float b, float r, float n) 
{
	if ((a < r) && (b < r)) {
		float2 p = float2(a, b);
		float columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));
		pR45(p);
		p.x -= sqrt(2)/2*r;
		p.x += columnradius*sqrt(2);
		if (abs(n%2) == 1) {
			p.y += columnradius;
		}
		// At this point, we have turned 45 degrees and moved at a point on the
		// diagonal that we want to place the columns on.
		// Now, repeat the domain along this direction and place a circle.
		pMod1(p.y, columnradius*2);
		float result = length(p) - columnradius;
		result = min(result, p.x);
		result = min(result, a);
		return min(result, b);
	} else {
		return min(a, b);
	}
}

float fOpDifferenceColumns(float a, float b, float r, float n) 
{
	a = -a;
	float m = min(a, b);
	//avoid the expensive computation where not needed (produces discontinuity though)
	if ((a < r) && (b < r)) {
		float2 p = float2(a, b);
		float columnradius = r*sqrt(2)/n/2.0;
		columnradius = r*sqrt(2)/((n-1)*2+sqrt(2));

		pR45(p);
		p.y += columnradius;
		p.x -= sqrt(2)/2*r;
		p.x += -columnradius*sqrt(2)/2;

		if (abs(n%2) == 1) {
			p.y += columnradius;
		}
		pMod1(p.y,columnradius*2);

		float result = -length(p) + columnradius;
		result = max(result, p.x);
		result = min(result, a);
		return -min(result, b);
	} else {
		return -m;
	}
}

float fOpIntersectionColumns(float a, float b, float r, float n) {
	return fOpDifferenceColumns(a,-b,r, n);
}

float fOpUnionStairs(float a, float b, float r, float n) 
{
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs (( abs((u - a + s) % (2 * s))) - s)));
}


float fOpIntersectionStairs(float a, float b, float r, float n) 
{
	return -fOpUnionStairs(-a, -b, r, n);
}

float fOpDifferenceStairs(float a, float b, float r, float n) 
{
	return -fOpUnionStairs(-a, b, r, n);
}


float fOpPipe(float a, float b, float r) 
{
	return length(float2(a, b)) - r;
}

float fOpEngrave(float a, float b, float r) {
	return max(a, (a + r - abs(b))*sqrt(0.5));
}

float fOpGroove(float a, float b, float ra, float rb) {
	return max(a, min(a + ra, rb - abs(b)));
}

float fOpTongue(float a, float b, float ra, float rb) {
	return min(a, max(a - ra, abs(b) - rb));
}
//////////////////////////////////////////////////////////////////////////


[numthreads(8, 8, 8)]
void CS_U( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = U(volA[ti], volB[ti]); }
[numthreads(8, 8, 8)]
void CS_S( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = S(volA[ti], volB[ti]); }
[numthreads(8, 8, 8)]
void CS_I( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = I(volA[ti], volB[ti]); }


[numthreads(8, 8, 8)]
void CS_UnionChamfer( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpUnionChamfer(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_IntersectionChamfer( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpIntersectionChamfer(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_DifferenceChamfer( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpDifferenceChamfer(volA[ti], volB[ti], p1); }

[numthreads(8, 8, 8)]
void CS_UnionRound( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpUnionRound(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_IntersectionRound( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpIntersectionRound(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_DifferenceRound( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpDifferenceRound(volA[ti], volB[ti], p1); }

[numthreads(8, 8, 8)]
void CS_UnionColumns( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpUnionColumns(volA[ti], volB[ti], p1, p2); }
[numthreads(8, 8, 8)]
void CS_IntersectionColumns( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpIntersectionColumns(volA[ti], volB[ti], p1, p2); }
[numthreads(8, 8, 8)]
void CS_DifferenceColumns( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpDifferenceColumns(volA[ti], volB[ti], p1, p2); }

[numthreads(8, 8, 8)]
void CS_UnionStairs( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpUnionStairs(volA[ti], volB[ti], p1, p2); }
[numthreads(8, 8, 8)]
void CS_IntersectionStairs( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpIntersectionStairs(volA[ti], volB[ti], p1, p2); }
[numthreads(8, 8, 8)]
void CS_DifferenceStairs( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpDifferenceStairs(volA[ti], volB[ti], p1, p2); }

[numthreads(8, 8, 8)]
void CS_Pipe( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpPipe(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_Engrave( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpEngrave(volA[ti], volB[ti], p1); }
[numthreads(8, 8, 8)]
void CS_Groove( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpGroove(volA[ti], volB[ti], p1, p2); }
[numthreads(8, 8, 8)]
void CS_Tongue( uint3 ti : SV_DispatchThreadID)
{ RWDistanceVolume[ti] = fOpTongue(volA[ti], volB[ti], p1, p2); }





technique11 Union{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_U() ) );}}
technique11 Intersect{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_I() ) );}}
technique11 Difference{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_S() ) );}}

technique11 UnionChamfer{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_UnionChamfer() ) );}}
technique11 IntersectionChamfer{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_IntersectionChamfer() ) );}}
technique11 DifferenceChamfer{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_DifferenceChamfer() ) );}}

technique11 UnionRound{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_UnionRound() ) );}}
technique11 IntersectionRound{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_IntersectionRound() ) );}}
technique11 DifferenceRound{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_DifferenceRound() ) );}}

technique11 UnionColumns{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_UnionColumns() ) );}}
technique11 IntersectionColumns{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_IntersectionColumns() ) );}}
technique11 DifferenceColumns{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_DifferenceColumns() ) );}}

technique11 UnionStairs{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_UnionStairs() ) );}}
technique11 IntersectionStairs{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_IntersectionStairs() ) );}}
technique11 DifferenceStairs{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_DifferenceStairs() ) );}}

technique11 Pipe{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Pipe() ) );}}
technique11 Engrave{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Engrave() ) );}}
technique11 Groove{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Groove() ) );}}
technique11 Tongue{pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Tongue() ) );}}

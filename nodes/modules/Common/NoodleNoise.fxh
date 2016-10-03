/*
NOODLE NOISE


Basic Usage
////////////////////////////////////////////////////////////////////////////////////
FractalType.NosieType(Parameters);

all noise types are overloaded for 2D & 3D noise
////////////////////////////////////////////////////////////////////////////////////

Fractal Sums
////////////////////////////////////////////////////////////////////////////////////
Noise			(just a single octave, only pos & freq needed)
FBM				
Turbulence
Ridge
////////////////////////////////////////////////////////////////////////////////////

Noise Types
////////////////////////////////////////////////////////////////////////////////////
Perlin						
PerlinD 	//returns float3(noise, derivitives.xy) or float4(noise, derivitives.xyz) for 2D/3D
Simplex
SimplexD  	//returns float3(noise, derivitives.xy) or float4(noise, derivitives.xyz) for 2D/3D
FastWorley
FastWorleyD //returns float3(noise, derivitives.xy) or float4(noise, derivitives.xyz) for 2D/3D
////////////////////////////////////////////////////////////////////////////////////

Parameters
////////////////////////////////////////////////////////////////////////////////////
//2D noise
float2 p, float freq, float pers, float lacun, int oct 
float3 p, float freq, float pers, float lacun, int oct  
only p is strictly required, all others have defaults.  

The Noise.Noisetype sum method only uses
pos & freq, but does not mind if you pass it the longer signature
////////////////////////////////////////////////////////////////////////////////////

Advanced Worley Noise Types
////////////////////////////////////////////////////////////////////////////////////
Worley
worley3D    //returns float3(noise, derivitives.xy) or float4(noise, derivitives.xyz) for 2D/3D
////////////////////////////////////////////////////////////////////////////////////

they have two extra items at the start of the signature:
//2D noise
(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct);
//3D noise
(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct);
////////////////////////////////////////////////////////////////////////////////////

cellDistance options
////////////////////////////////////////////////////////////////////////////////////
EuclideanSquared
Euclidean
Chebyshev
Manhattan
Minkowski
////////////////////////////////////////////////////////////////////////////////////

cellFunction options
////////////////////////////////////////////////////////////////////////////////////
F1
F2
F2MinusF1
Average
Crackle
////////////////////////////////////////////////////////////////////////////////////

see http://mines.lumpylumpy.com/Electronics/Computers/Software/Cpp/Graphics/Bitmap/Textures/Noise/Voronoi.php#.Vv3qPXqzKYj

you can pass one of the above  as parmeter or copy paste the interface in to your shader to choose on the fly 
iCellDist cellDistance <string linkclass="EuclideanSquared,Euclidean,Chebyshev,Manhattan,Minkowski";>;
iCellFunc cellFunction <string linkclass="F1,F2,F2MinusF1,Average,Crackle";>;
////////////////////////////////////////////////////////////////////////////////////

Examples
////////////////////////////////////////////////////////////////////////////////////
Noise.Perlin(P, 2, 1.2, 1.9, 5) 
// Computes a single octave of perlin noise at freq=2

Noise.Perlin(P, 2)				
//  Also works and is same as above

Noise.FastWorly(P, 2, 1.2, 1.9, 5)
// Computes a single octave of fast worley noise at freq=2

FBM.Perlin(P, 2, 1.2, 1.9, 5)	
// Computes a FbM sum of 5 octaves of perlin noise

Ridge.Simplex(P, 2, 1.2, 1.9, 5)  
// Computes a Ridge sum of 5 octaves of simplex noise

FBM.Worley(Chebyshev, F2MinusF1, P, 2, 1.2, 1.9, 5)
// Computes a FbM sum of 5 octaves of worley noise using Chebyshev distance & F2 - F1

////////////////////////////////////////////////////////////////////////////////////

*/

////////////////////////////////////////////////////////////////////////////////////
float3 computeCurl (float3 d)
{
	float3 curl;
	curl.x = d.y - d.z;
	curl.y = d.z - d.x;
	curl.z = d.x - d.z;
	return curl;
}


float4 hashCell ( float2 gridcell ) //  generates 4 different random numbers for the single given cell point
{
    //  gridcell is assumed to be an integer coordinate
    float2 OFFSET = float2( 26.0, 161.0 );
    float DOMAIN = 71.0;
    float4 SOMELARGEFLOATS = float4( 951.135664, 642.949883, 803.202459, 986.973274 );
    float2 P = gridcell - floor(gridcell * ( 1.0 / DOMAIN )) * DOMAIN;
    P += OFFSET.xy;
    P *= P;
    return frac( (P.x * P.y) * ( 1.0 / SOMELARGEFLOATS.xyzw ) );
}
float4 hashCell ( float3 gridcell ) //  generates 4 different random numbers for the single given cell point
{
    //    gridcell is assumed to be an integer coordinate
    float2 OFFSET = float2( 50.0, 161.0 );
    float DOMAIN = 69.0;
    float4 SOMELARGEFLOATS = float4( 635.298681, 682.357502, 668.926525, 588.255119 );
    float4 ZINC = float4( 48.500388, 65.294118, 63.934599, 63.279683 );
    //  truncate the domain
    gridcell.xyz = gridcell - floor(gridcell * ( 1.0 / DOMAIN )) * DOMAIN;
    gridcell.xy += OFFSET.xy;
    gridcell.xy *= gridcell.xy;
    return frac( ( gridcell.x * gridcell.y ) * ( 1.0 / ( SOMELARGEFLOATS + gridcell.zzzz * ZINC ) ) );
}
////////////////////////////////////////////////////////////////////////////////////

#define SOMELARGEFLOATS float3( 635.298681, 682.357502, 668.926525 )
#define ZINC float3( 48.500388, 65.294118, 63.934599 )

//  Noise textureless basis functions from https://github.com/BrianSharpe/Wombat/
////////////////////////////////////////////////////////////////////////////////////
//  Perlin Noise 2D
//  Return value range of -1.0->1.0
////////////////////////////////////////////////////////////////////////////////////
float perlin2D( float2 P )
{
    // establish our grid cell and unit position
    float2 Pi = floor(P);
    float4 Pf_Pfmin1 = P.xyxy - float4( Pi, Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    // calculate the gradient results
    float4 grad_x = hash_x - 0.49999;
    float4 grad_y = hash_y - 0.49999;
    float4 grad_results = rsqrt( grad_x * grad_x + grad_y * grad_y ) * ( grad_x * Pf_Pfmin1.xzxz + grad_y * Pf_Pfmin1.yyww );

    // Classic Perlin Interpolation
    grad_results *= 1.4142135623730950488016887242097;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.5)
    float2 blend = Pf_Pfmin1.xy * Pf_Pfmin1.xy * Pf_Pfmin1.xy * (Pf_Pfmin1.xy * (Pf_Pfmin1.xy * 6.0 - 15.0) + 10.0);
    float4 blend2 = float4( blend, float2( 1.0 - blend ) );
    return dot( grad_results, blend2.zxzx * blend2.wwyy );
}

////////////////////////////////////////////////////////////////////////////////////
//  Perlin Noise 2D Deriv
//  Return value range of -1.0->1.0, with format float3( value, xderiv, yderiv )
////////////////////////////////////////////////////////////////////////////////////
float3 perlin2D_Deriv( float2 P )
{
    // establish our grid cell and unit position
    float2 Pi = floor(P);
    float4 Pf_Pfmin1 = P.xyxy - float4( Pi, Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    // calculate the gradient results
    float4 grad_x = hash_x - 0.49999;
    float4 grad_y = hash_y - 0.49999;
    float4 norm = rsqrt( grad_x * grad_x + grad_y * grad_y );
    grad_x *= norm;
    grad_y *= norm;
    float4 dotval = ( grad_x * Pf_Pfmin1.xzxz + grad_y * Pf_Pfmin1.yyww );

    //	C2 Interpolation
    float4 blend = Pf_Pfmin1.xyxy * Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * ( Pf_Pfmin1.xyxy * float2( 6.0, 0.0 ).xxyy + float2( -15.0, 30.0 ).xxyy ) + float2( 10.0, -60.0 ).xxyy ) + float2( 0.0, 30.0 ).xxyy );

    //	Convert our data to a more parallel format
    float3 dotval0_grad0 = float3( dotval.x, grad_x.x, grad_y.x );
    float3 dotval1_grad1 = float3( dotval.y, grad_x.y, grad_y.y );
    float3 dotval2_grad2 = float3( dotval.z, grad_x.z, grad_y.z );
    float3 dotval3_grad3 = float3( dotval.w, grad_x.w, grad_y.w );

    //	evaluate common constants
    float3 k0_gk0 = dotval1_grad1 - dotval0_grad0;
    float3 k1_gk1 = dotval2_grad2 - dotval0_grad0;
    float3 k2_gk2 = dotval3_grad3 - dotval2_grad2 - k0_gk0;

    //	calculate final noise + deriv
    float3 results = dotval0_grad0
                    + blend.x * k0_gk0
                    + blend.y * ( k1_gk1 + blend.x * k2_gk2 );
    results.yz += blend.zw * ( float2( k0_gk0.x, k1_gk1.x ) + blend.yx * k2_gk2.xx );
    return results * 1.4142135623730950488016887242097;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.5)
}
////////////////////////////////////////////////////////////////////////////////////
//  Perlin Noise 3D
//  Return value range of -1.0->1.0
////////////////////////////////////////////////////////////////////////////////////
float perlin3D( float3 P )
{
    // establish our grid cell and unit position
    float3 Pi = floor(P);
    float3 Pf = P - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hashx0 = frac( Pt * lowz_mod.xxxx );
    float4 hashx1 = frac( Pt * highz_mod.xxxx );
    float4 hashy0 = frac( Pt * lowz_mod.yyyy );
    float4 hashy1 = frac( Pt * highz_mod.yyyy );
    float4 hashz0 = frac( Pt * lowz_mod.zzzz );
    float4 hashz1 = frac( Pt * highz_mod.zzzz );

    // calculate the gradients
    float4 grad_x0 = hashx0 - 0.49999;
    float4 grad_y0 = hashy0 - 0.49999;
    float4 grad_z0 = hashz0 - 0.49999;
    float4 grad_x1 = hashx1 - 0.49999;
    float4 grad_y1 = hashy1 - 0.49999;
    float4 grad_z1 = hashz1 - 0.49999;
    float4 grad_results_0 = rsqrt( grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0 ) * ( float2( Pf.x, Pf_min1.x ).xyxy * grad_x0 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y0 + Pf.zzzz * grad_z0 );
    float4 grad_results_1 = rsqrt( grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1 ) * ( float2( Pf.x, Pf_min1.x ).xyxy * grad_x1 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1 );

    // Classic Perlin Interpolation
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float4 res0 = lerp( grad_results_0, grad_results_1, blend.z );
    float4 blend2 = float4( blend.xy, float2( 1.0 - blend.xy ) );
    float final = dot( res0, blend2.zxzx * blend2.wwyy );
	
    return ( final * 1.1547005383792515290182975610039);  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.75)
}

//  Perlin Noise 3D Deriv
//  Return value range of -1.0->1.0, with format float4( value, xderiv, yderiv, zderiv )
//
float4 perlin3D_Deriv( float3 P )
{
    // establish our grid cell and unit position
    float3 Pi = floor(P);
    float3 Pf = P - Pi;
    float3 Pf_min1 = Pf - 1.0;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;

	
	
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hashx0 = frac( Pt * lowz_mod.xxxx );
    float4 hashx1 = frac( Pt * highz_mod.xxxx );
    float4 hashy0 = frac( Pt * lowz_mod.yyyy );
    float4 hashy1 = frac( Pt * highz_mod.yyyy );
    float4 hashz0 = frac( Pt * lowz_mod.zzzz );
    float4 hashz1 = frac( Pt * highz_mod.zzzz );

    //  calculate the gradients
    float4 grad_x0 = hashx0 - 0.49999;
    float4 grad_y0 = hashy0 - 0.49999;
    float4 grad_z0 = hashz0 - 0.49999;
    float4 grad_x1 = hashx1 - 0.49999;
    float4 grad_y1 = hashy1 - 0.49999;
    float4 grad_z1 = hashz1 - 0.49999;
    float4 norm_0 = rsqrt( grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0 );
    float4 norm_1 = rsqrt( grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1 );
    grad_x0 *= norm_0;
    grad_y0 *= norm_0;
    grad_z0 *= norm_0;
    grad_x1 *= norm_1;
    grad_y1 *= norm_1;
    grad_z1 *= norm_1;

    //  calculate the dot products
    float4 dotval_0 = float2( Pf.x, Pf_min1.x ).xyxy * grad_x0 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y0 + Pf.zzzz * grad_z0;
    float4 dotval_1 = float2( Pf.x, Pf_min1.x ).xyxy * grad_x1 + float2( Pf.y, Pf_min1.y ).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1;

    //  C2 Interpolation
    float3 blend = Pf * Pf * Pf * (Pf * (Pf * 6.0 - 15.0) + 10.0);
    float3 blendDeriv = Pf * Pf * (Pf * (Pf * 30.0 - 60.0) + 30.0);

    //  the following is based off Milo Yips derivation, but modified for parallel execution
    //  http://stackoverflow.com/a/14141774

    //  Convert our data to a more parallel format
    float4 dotval0_grad0 = float4( dotval_0.x, grad_x0.x, grad_y0.x, grad_z0.x );
    float4 dotval1_grad1 = float4( dotval_0.y, grad_x0.y, grad_y0.y, grad_z0.y );
    float4 dotval2_grad2 = float4( dotval_0.z, grad_x0.z, grad_y0.z, grad_z0.z );
    float4 dotval3_grad3 = float4( dotval_0.w, grad_x0.w, grad_y0.w, grad_z0.w );
    float4 dotval4_grad4 = float4( dotval_1.x, grad_x1.x, grad_y1.x, grad_z1.x );
    float4 dotval5_grad5 = float4( dotval_1.y, grad_x1.y, grad_y1.y, grad_z1.y );
    float4 dotval6_grad6 = float4( dotval_1.z, grad_x1.z, grad_y1.z, grad_z1.z );
    float4 dotval7_grad7 = float4( dotval_1.w, grad_x1.w, grad_y1.w, grad_z1.w );

    //  evaluate common constants
    float4 k0_gk0 = dotval1_grad1 - dotval0_grad0;
    float4 k1_gk1 = dotval2_grad2 - dotval0_grad0;
    float4 k2_gk2 = dotval4_grad4 - dotval0_grad0;
    float4 k3_gk3 = dotval3_grad3 - dotval2_grad2 - k0_gk0;
    float4 k4_gk4 = dotval5_grad5 - dotval4_grad4 - k0_gk0;
    float4 k5_gk5 = dotval6_grad6 - dotval4_grad4 - k1_gk1;
    float4 k6_gk6 = (dotval7_grad7 - dotval6_grad6) - (dotval5_grad5 - dotval4_grad4) - k3_gk3;

    //  calculate final noise + deriv
    float u = blend.x;
    float v = blend.y;
    float w = blend.z;
    float4 result = dotval0_grad0
        + u * ( k0_gk0 + v * k3_gk3 )
        + v * ( k1_gk1 + w * k5_gk5 )
        + w * ( k2_gk2 + u * ( k4_gk4 + v * k6_gk6 ) );
    result.y += dot( float4( k0_gk0.x, k3_gk3.x * v, float2( k4_gk4.x, k6_gk6.x * v ) * w ), float4( blendDeriv.xxxx ) );
    result.z += dot( float4( k1_gk1.x, k3_gk3.x * u, float2( k5_gk5.x, k6_gk6.x * u ) * w ), float4( blendDeriv.yyyy ) );
    result.w += dot( float4( k2_gk2.x, k4_gk4.x * u, float2( k5_gk5.x, k6_gk6.x * u ) * v ), float4( blendDeriv.zzzz ) );
    return result * 1.1547005383792515290182975610039;  // scale things to a strict -1.0->1.0 range  *= 1.0/sqrt(0.75)
}

////////////////////////////////////////////////////////////////////////////////////
//  Simplex Perlin Noise 2D
//  Return value range of -1.0->1.0
////////////////////////////////////////////////////////////////////////////////////
float simplex2D( float2 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/SimplexPerlin2D.glsl

    //  simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;            // 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;          // (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;    // sqrt( 0.5 )	height of simplex triangle
    const float3 SIMPLEX_POINTS = float3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );  //  simplex triangle geo

    //  establish our grid cell.
    P *= SIMPLEX_TRI_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float2 Pi = floor( P + dot( P, float2( SKEWFACTOR.xx ) ) );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  establish floattors to the 3 corners of our simplex triangle
    float2 v0 = Pi - dot( Pi, float2( UNSKEWFACTOR.xx ) ) - P;
    float4 v1pos_v1hash = (v0.x < v0.y) ? float4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : float4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    float4 v12 = float4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //  calculate the dotproduct of our 3 corner floattors with 3 random normalized floattors
    float3 grad_x = float3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    float3 grad_y = float3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    float3 grad_results = rsqrt( grad_x * grad_x + grad_y * grad_y ) * ( grad_x * float3( v0.x, v12.xz ) + grad_y * float3( v0.y, v12.yw ) );

    //	Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //	http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;

    //	evaluate and return
    float3 m = float3( v0.x, v12.xz ) * float3( v0.x, v12.xz ) + float3( v0.y, v12.yw ) * float3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);
    m = m*m;
    return dot(m*m, grad_results) * FINAL_NORMALIZATION;
}

/////////////////////////////////////////////////////////////////////////////////////
//  Simplex Perlin Noise 2D Deriv
//  Return value range of -1.0->1.0, with format float3( value, xderiv, yderiv )
////////////////////////////////////////////////////////////////////////////////////
float3 simplex2D_Deriv( float2 P )
{
    //  simplex math constants
    const float SKEWFACTOR = 0.36602540378443864676372317075294;            // 0.5*(sqrt(3.0)-1.0)
    const float UNSKEWFACTOR = 0.21132486540518711774542560974902;          // (3.0-sqrt(3.0))/6.0
    const float SIMPLEX_TRI_HEIGHT = 0.70710678118654752440084436210485;    // sqrt( 0.5 )	height of simplex triangle
    const float3 SIMPLEX_POINTS = float3( 1.0-UNSKEWFACTOR, -UNSKEWFACTOR, 1.0-2.0*UNSKEWFACTOR );  //  simplex triangle geo

    //  establish our grid cell.
    P *= SIMPLEX_TRI_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float2 Pi = floor( P + dot( P, float2( SKEWFACTOR.xx ) ) );

    // calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  establish floattors to the 3 corners of our simplex triangle
    float2 v0 = Pi - dot( Pi, float2( UNSKEWFACTOR.xx ) ) - P;
    float4 v1pos_v1hash = (v0.x < v0.y) ? float4(SIMPLEX_POINTS.xy, hash_x.y, hash_y.y) : float4(SIMPLEX_POINTS.yx, hash_x.z, hash_y.z);
    float4 v12 = float4( v1pos_v1hash.xy, SIMPLEX_POINTS.zz ) + v0.xyxy;

    //  calculate the dotproduct of our 3 corner floattors with 3 random normalized floattors
    float3 grad_x = float3( hash_x.x, v1pos_v1hash.z, hash_x.w ) - 0.49999;
    float3 grad_y = float3( hash_y.x, v1pos_v1hash.w, hash_y.w ) - 0.49999;
    float3 norm = rsqrt( grad_x * grad_x + grad_y * grad_y );
    grad_x *= norm;
    grad_y *= norm;
    float3 grad_results = grad_x * float3( v0.x, v12.xz ) + grad_y * float3( v0.y, v12.yw );

    //	evaluate the kernel
    float3 m = float3( v0.x, v12.xz ) * float3( v0.x, v12.xz ) + float3( v0.y, v12.yw ) * float3( v0.y, v12.yw );
    m = max(0.5 - m, 0.0);
    float3 m2 = m*m;
    float3 m4 = m2*m2;

    //  calc the derivatives
    float3 temp = 8.0 * m2 * m * grad_results;
    float xderiv = dot( temp, float3( v0.x, v12.xz ) ) - dot( m4, grad_x );
    float yderiv = dot( temp, float3( v0.y, v12.yw ) ) - dot( m4, grad_y );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    const float FINAL_NORMALIZATION = 99.204334582718712976990005025589;

    //  sum and return all results as a float3
    return float3( dot( m4, grad_results ), xderiv, yderiv ) * FINAL_NORMALIZATION;
}

////////////////////////////////////////////////////////////////////////////////////
//  Simplex Perlin Noise 3D
//  Return value range of -1.0->1.0
////////////////////////////////////////////////////////////////////////////////////



float simplex3D( float3 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/SimplexPerlin3D.glsl

	//  simplex math constants
 	const float SKEWFACTOR = 1.0/3.0;
 	const float UNSKEWFACTOR = 1.0/6.0;
 	const float SIMPLEX_CORNER_POS = 0.5;
 	const float SIMPLEX_TETRAHADRON_HEIGHT = 0.70710678118654752440084436210485 ;  // sqrt( 0.5 )

    //  establish our grid cell.
    P *= SIMPLEX_TETRAHADRON_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float3 Pi = floor( P + dot( P, SKEWFACTOR) );

    //  Find the vectors to the corners of our simplex tetrahedron
    float3 x0 = P - Pi + dot(Pi, UNSKEWFACTOR);
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 Pi_1 = min( g.xyz, l.zxy );
    float3 Pi_2 = max( g.xyz, l.zxy );
    float3 x1 = x0 - Pi_1 + UNSKEWFACTOR;
    float3 x2 = x0 - Pi_2 + SKEWFACTOR;
    float3 x3 = x0 - SIMPLEX_CORNER_POS;

    //  pack them into a parallel-friendly arrangement
    float4 v1234_x = float4( x0.x, x1.x, x2.x, x3.x );
    float4 v1234_y = float4( x0.y, x1.y, x2.y, x3.y );
    float4 v1234_z = float4( x0.z, x1.z, x2.z, x3.z );

    // clamp the domain of our grid cell
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    //  generate the random vectors
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    float4 V1xy_V2xy = lerp( Pt.xyxy, Pt.zwzw, float4( Pi_1.xy, Pi_2.xy ) );
    Pt = float4( Pt.x, V1xy_V2xy.xz, Pt.z ) * float4( Pt.y, V1xy_V2xy.yw, Pt.w );

    float3 lowz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi.zzz * ZINC.xyz ) );
    float3 highz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi_inc1.zzz * ZINC.xyz ) );
    Pi_1 = ( Pi_1.z < 0.5 ) ? lowz_mods : highz_mods;
    Pi_2 = ( Pi_2.z < 0.5 ) ? lowz_mods : highz_mods;
    float4 hash_0 = frac( Pt * float4( lowz_mods.x, Pi_1.x, Pi_2.x, highz_mods.x ) ) - 0.49999;
    float4 hash_1 = frac( Pt * float4( lowz_mods.y, Pi_1.y, Pi_2.y, highz_mods.y ) ) - 0.49999;
    float4 hash_2 = frac( Pt * float4( lowz_mods.z, Pi_1.z, Pi_2.z, highz_mods.z ) ) - 0.49999;

    //  evaluate gradients
    float4 grad_results = rsqrt( hash_0 * hash_0 + hash_1 * hash_1 + hash_2 * hash_2 ) * ( hash_0 * v1234_x + hash_1 * v1234_y + hash_2 * v1234_z );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36
    #define FINAL_NORMALIZATION 37.837227241611314102871574478976

    //  evaulate the kernel weights ( use (0.5-x*x)^3 instead of (0.6-x*x)^4 to fix discontinuities )
    float4 kernel_weights = v1234_x * v1234_x + v1234_y * v1234_y + v1234_z * v1234_z;
    kernel_weights = max(0.5 - kernel_weights, 0.0);
    kernel_weights = kernel_weights*kernel_weights*kernel_weights;

    //  sum with the kernel and return
    return dot( kernel_weights, grad_results ) * FINAL_NORMALIZATION;
}

//  Simplex Perlin Noise 3D Deriv
//  Return value range of -1.0->1.0, with format float4( value, xderiv, yderiv, zderiv )
//
float4 simplex3D_Deriv(float3 P)
{
 	const float SKEWFACTOR = 1.0/3.0;
 	const float UNSKEWFACTOR = 1.0/6.0;
 	const float SIMPLEX_CORNER_POS = 0.5;
 	const float SIMPLEX_TETRAHADRON_HEIGHT = 0.70710678118654752440084436210485 ;  // sqrt( 0.5 )
	
    //  establish our grid cell.
    P *= SIMPLEX_TETRAHADRON_HEIGHT;    // scale space so we can have an approx feature size of 1.0
    float3 Pi = floor( P + dot( P, SKEWFACTOR) );

    //  Find the vectors to the corners of our simplex tetrahedron
    float3 x0 = P - Pi + dot(Pi, UNSKEWFACTOR);
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 Pi_1 = min( g.xyz, l.zxy );
    float3 Pi_2 = max( g.xyz, l.zxy );
    float3 x1 = x0 - Pi_1 + UNSKEWFACTOR;
    float3 x2 = x0 - Pi_2 + SKEWFACTOR;
    float3 x3 = x0 - SIMPLEX_CORNER_POS;

    //  pack them into a parallel-friendly arrangement
    float4 v1234_x = float4( x0.x, x1.x, x2.x, x3.x );
    float4 v1234_y = float4( x0.y, x1.y, x2.y, x3.y );
    float4 v1234_z = float4( x0.z, x1.z, x2.z, x3.z );

    // clamp the domain of our grid cell
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step(Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    //  generate the random vectors
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    float4 V1xy_V2xy = lerp( Pt.xyxy, Pt.zwzw, float4( Pi_1.xy, Pi_2.xy ) );
    Pt = float4( Pt.x, V1xy_V2xy.xz, Pt.z ) * float4( Pt.y, V1xy_V2xy.yw, Pt.w );
    float3 lowz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi.zzz * ZINC.xyz ) );
    float3 highz_mods = float3( 1.0 / ( SOMELARGEFLOATS.xyz + Pi_inc1.zzz * ZINC.xyz ) );
    Pi_1 = ( Pi_1.z < 0.5 ) ? lowz_mods : highz_mods;
    Pi_2 = ( Pi_2.z < 0.5 ) ? lowz_mods : highz_mods;
    float4 hash_0 = frac( Pt * float4( lowz_mods.x, Pi_1.x, Pi_2.x, highz_mods.x ) ) - 0.49999;
    float4 hash_1 = frac( Pt * float4( lowz_mods.y, Pi_1.y, Pi_2.y, highz_mods.y ) ) - 0.49999;
    float4 hash_2 = frac( Pt * float4( lowz_mods.z, Pi_1.z, Pi_2.z, highz_mods.z ) ) - 0.49999;

    //  normalize random gradient vectors
    float4 norm = rsqrt( hash_0 * hash_0 + hash_1 * hash_1 + hash_2 * hash_2 );
    hash_0 *= norm;
    hash_1 *= norm;
    hash_2 *= norm;

    //  evaluate gradients
    float4 grad_results = hash_0 * v1234_x + hash_1 * v1234_y + hash_2 * v1234_z;

    //  evaulate the kernel weights ( use (0.5-x*x)^3 instead of (0.6-x*x)^4 to fix discontinuities )
    float4 m = v1234_x * v1234_x + v1234_y * v1234_y + v1234_z * v1234_z;
    m = max(0.5 - m, 0.0);
    float4 m2 = m*m;
    float4 m3 = m*m2;

    //  calc the derivatives
    float4 temp = -6.0 * m2 * grad_results;
    float xderiv = dot( temp, v1234_x ) + dot( m3, hash_0 );
    float yderiv = dot( temp, v1234_y ) + dot( m3, hash_1 );
    float zderiv = dot( temp, v1234_z ) + dot( m3, hash_2 );

    //  Normalization factor to scale the final result to a strict 1.0->-1.0 range
    //  http://briansharpe.wordpress.com/2012/01/13/simplex-noise/#comment-36


    //  sum and return all results as a float3
    return float4( dot( m3, grad_results ), xderiv, yderiv, zderiv ) * FINAL_NORMALIZATION;
}


///////////////////////////////////////////////////////////////////
//  Cellular Noise 2D
//  produces a range of 0.0->1.0
//
float fastWorley2D( float2 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular2D.glsl

	const float JITTER_WINDOW = 0.25;   // 0.25 will guarentee no artifacts
	
    //  establish our grid cell and unit position
    float2 Pi = floor(P);
    float2 Pf = P - Pi;

    //  calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  generate the 4 points
    hash_x = hash_x * 2.0 - 1.0;
    hash_y = hash_y * 2.0 - 1.0;
 
    hash_x = ( ( hash_x * hash_x * hash_x ) - sign( hash_x ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y = ( ( hash_y * hash_y * hash_y ) - sign( hash_y ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );

    //  return the closest squared distance
    float4 dx = Pf.xxxx - hash_x;
    float4 dy = Pf.yyyy - hash_y;
    float4 d = dx * dx + dy * dy;
	
    d.xy = min(d.xy, d.zw);
	return min(d.x, d.y) * ( 1.0 / 1.125 ); // return a value scaled to 0.0->1.0
	
	// distance & formula
	//d = max(abs(dx), abs(dy)); //Chebyshev
	//d = float4(min(d.xy, d.zw), max (d.xy, d.zw));
	//return  F2MinusF1.result( float2(min(d.x, d.y), max(d.x, d.y))) ;

}


//
//  Cellular Noise 2D Deriv
//  Return value range of 0.0->1.0, with format vec3( value, xderiv, yderiv )
//
float3 fastWorley2D_Deriv( float2 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular2D_Deriv.glsl

	const float JITTER_WINDOW = 0.25;   // 0.25 will guarentee no artifacts
    //  establish our grid cell and unit position
    float2 Pi = floor(P);
    float2 Pf = P - Pi;

    //  calculate the hash
    float4 Pt = float4( Pi.xy, Pi.xy + 1.0 );
    Pt = Pt - floor(Pt * ( 1.0 / 71.0 )) * 71.0;
    Pt += float2( 26.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float4 hash_x = frac( Pt * ( 1.0 / 951.135664 ) );
    float4 hash_y = frac( Pt * ( 1.0 / 642.949883 ) );

    //  generate the 4 points
    hash_x = hash_x * 2.0 - 1.0;
    hash_y = hash_y * 2.0 - 1.0;
    hash_x = ( ( hash_x * hash_x * hash_x ) - sign( hash_x ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y = ( ( hash_y * hash_y * hash_y ) - sign( hash_y ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );

    //	return the closest squared distance + derivatives ( thanks to Jonathan Dupuy )
    float4 dx = Pf.xxxx - hash_x;
    float4 dy = Pf.yyyy - hash_y;
    float4 d = dx * dx + dy * dy;
    float3 t1 = d.x < d.y ? float3( d.x, dx.x, dy.x ) : float3( d.y, dx.y, dy.y );
    float3 t2 = d.z < d.w ? float3( d.z, dx.z, dy.z ) : float3( d.w, dx.w, dy.w );
    return ( t1.x < t2.x ? t1 : t2 ) * float3( 1.0, 2.0, 2.0 ) * ( 1.0 / 1.125 ); // return a value scaled to 0.0->1.0
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Cellular Noise 3D
//  produces a range of 0.0->1.0
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
float fastWorley3D(float3 P)
{
    //	establish our grid cell and unit position
    float3 Pi = floor(P);
    float3 Pf = P - Pi;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5 ) * ( Pi + 1.0 );

    // calculate the hash ( over -1.0->1.0 range )
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;
    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hash_x0 = frac( Pt * lowz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_x1 = frac( Pt * highz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_y0 = frac( Pt * lowz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_y1 = frac( Pt * highz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_z0 = frac( Pt * lowz_mod.zzzz ) * 2.0 - 1.0;
    float4 hash_z1 = frac( Pt * highz_mod.zzzz ) * 2.0 - 1.0;

    //  generate the 8 point positions
    const float JITTER_WINDOW3 = 0.166666666;	// 0.166666666 will guarentee no artifacts.
    hash_x0 = ( ( hash_x0 * hash_x0 * hash_x0 ) - sign( hash_x0 ) ) * JITTER_WINDOW3 + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y0 = ( ( hash_y0 * hash_y0 * hash_y0 ) - sign( hash_y0 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_x1 = ( ( hash_x1 * hash_x1 * hash_x1 ) - sign( hash_x1 ) ) * JITTER_WINDOW3 + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y1 = ( ( hash_y1 * hash_y1 * hash_y1 ) - sign( hash_y1 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_z0 = ( ( hash_z0 * hash_z0 * hash_z0 ) - sign( hash_z0 ) ) * JITTER_WINDOW3 + float4( 0.0, 0.0, 0.0, 0.0 );
    hash_z1 = ( ( hash_z1 * hash_z1 * hash_z1 ) - sign( hash_z1 ) ) * JITTER_WINDOW3 + float4( 1.0, 1.0, 1.0, 1.0 );

    //	return the closest squared distance
    float4 dx1 = Pf.xxxx - hash_x0;
    float4 dy1 = Pf.yyyy - hash_y0;
    float4 dz1 = Pf.zzzz - hash_z0;
    float4 dx2 = Pf.xxxx - hash_x1;
    float4 dy2 = Pf.yyyy - hash_y1;
    float4 dz2 = Pf.zzzz - hash_z1;
    float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1;
    float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2;
    d1 = min(d1, d2);
    d1.xy = min(d1.xy, d1.wz);
    return min(d1.x, d1.y) * ( 9.0 / 12.0 ); // return a value scaled to 0.0->1.0
}


//  Cellular Noise 3D Deriv
//  Return value range of 0.0->1.0, with format float4( value, xderiv, yderiv, zderiv )
//
float4 fastWorley3D_Deriv( float3 P )
{
    //  https://github.com/BrianSharpe/Wombat/blob/master/Cellular3D_Deriv.glsl

    //  establish our grid cell and unit position
    float3 Pi = floor(P);
    float3 Pf = P - Pi;

    // clamp the domain
    Pi.xyz = Pi.xyz - floor(Pi.xyz * ( 1.0 / 69.0 )) * 69.0;
    float3 Pi_inc1 = step( Pi, 69.0 - 1.5) * ( Pi + 1.0 );

    // calculate the hash ( over -1.0->1.0 range )
    float4 Pt = float4( Pi.xy, Pi_inc1.xy ) + float2( 50.0, 161.0 ).xyxy;
    Pt *= Pt;
    Pt = Pt.xzxz * Pt.yyww;

    float3 lowz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi.zzz * ZINC ) );
    float3 highz_mod = float3( 1.0 / ( SOMELARGEFLOATS + Pi_inc1.zzz * ZINC ) );
    float4 hash_x0 = frac( Pt * lowz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_x1 = frac( Pt * highz_mod.xxxx ) * 2.0 - 1.0;
    float4 hash_y0 = frac( Pt * lowz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_y1 = frac( Pt * highz_mod.yyyy ) * 2.0 - 1.0;
    float4 hash_z0 = frac( Pt * lowz_mod.zzzz ) * 2.0 - 1.0;
    float4 hash_z1 = frac( Pt * highz_mod.zzzz ) * 2.0 - 1.0;

    //  generate the 8 point positions
    const float JITTER_WINDOW = 0.166666666;    // 0.166666666 will guarentee no artifacts.
    hash_x0 = ( ( hash_x0 * hash_x0 * hash_x0 ) - sign( hash_x0 ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y0 = ( ( hash_y0 * hash_y0 * hash_y0 ) - sign( hash_y0 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_x1 = ( ( hash_x1 * hash_x1 * hash_x1 ) - sign( hash_x1 ) ) * JITTER_WINDOW + float4( 0.0, 1.0, 0.0, 1.0 );
    hash_y1 = ( ( hash_y1 * hash_y1 * hash_y1 ) - sign( hash_y1 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 1.0, 1.0 );
    hash_z0 = ( ( hash_z0 * hash_z0 * hash_z0 ) - sign( hash_z0 ) ) * JITTER_WINDOW + float4( 0.0, 0.0, 0.0, 0.0 );
    hash_z1 = ( ( hash_z1 * hash_z1 * hash_z1 ) - sign( hash_z1 ) ) * JITTER_WINDOW + float4( 1.0, 1.0, 1.0, 1.0 );

    //  return the closest squared distance + derivatives ( thanks to Jonathan Dupuy )
    float4 dx1 = Pf.xxxx - hash_x0;
    float4 dy1 = Pf.yyyy - hash_y0;
    float4 dz1 = Pf.zzzz - hash_z0;
    float4 dx2 = Pf.xxxx - hash_x1;
    float4 dy2 = Pf.yyyy - hash_y1;
    float4 dz2 = Pf.zzzz - hash_z1;
    float4 d1 = dx1 * dx1 + dy1 * dy1 + dz1 * dz1;
    float4 d2 = dx2 * dx2 + dy2 * dy2 + dz2 * dz2;
    float4 r1 = d1.x < d1.y ? float4( d1.x, dx1.x, dy1.x, dz1.x ) : float4( d1.y, dx1.y, dy1.y, dz1.y );
    float4 r2 = d1.z < d1.w ? float4( d1.z, dx1.z, dy1.z, dz1.z ) : float4( d1.w, dx1.w, dy1.w, dz1.w );
    float4 r3 = d2.x < d2.y ? float4( d2.x, dx2.x, dy2.x, dz2.x ) : float4( d2.y, dx2.y, dy2.y, dz2.y );
    float4 r4 = d2.z < d2.w ? float4( d2.z, dx2.z, dy2.z, dz2.z ) : float4( d2.w, dx2.w, dy2.w, dz2.w );
    float4 t1 = r1.x < r2.x ? r1 : r2;
    float4 t2 = r3.x < r4.x ? r3 : r4;
    return ( t1.x < t2.x ? t1 : t2 ) * float4( 1.0, 2.0, 2.0, 2.0  ) * ( 9.0 / 12.0 ); // return a value scaled to 0.0->1.0
}


/////////////////////////////////////////////
// Worley Helpers
////////////////////////////////////////////
interface iCellDist 
{
float get(float3 offset);
float get(float2 offset);
};

class cEuclidean : iCellDist
{
	float get(float3 offset)
	{
		return  sqrt(dot( offset, offset ));
	}
	float get(float2 offset)
	{
		return  sqrt(dot( offset, offset ));
	}
};
class cEuclideanSquared : iCellDist
{
	float get(float3 offset)
	{
		return  dot( offset, offset );
	}
	
	float get(float2 offset)
	{
		return  dot( offset, offset );
	}
};
class cChebyshev : iCellDist
{
	float get(float3 offset)
	{
		offset = abs(offset);
		return max(offset.x,max(offset.y, offset.z));	  
	}
	
	float get(float2 offset)
	{
		offset = abs(offset);
		return max(offset.x,offset.y);	  
	}
};
class cManhattan : iCellDist
{
	float get(float3 offset)
	{
		offset = abs(offset);
		return offset.x + offset.y + offset.z;  
	}
	
	float get(float2 offset)
	{
		offset = abs(offset);
		return offset.x + offset.y;  
	}
};
class cMinkowski : iCellDist
{
	float get(float3 offset)
	{
		offset = abs(offset);
		float p = 4;
		return pow(pow(offset.x, p) + pow(offset.y, p) + pow(offset.z, p), 1.0/p);  
	}
	
	float get(float2 offset)
	{
		offset = abs(offset);
		float p = 4;
		return pow(pow(offset.x, p) + pow(offset.y, p), 1.0/p);  
	}
};
cEuclidean Euclidean;
cEuclideanSquared EuclideanSquared;
cChebyshev Chebyshev;
cManhattan Manhattan;
cMinkowski Minkowski;

interface iCellFunc {float result(float2 dist); };
class cF1 : iCellFunc
{
	float result(float2 dist)
	{
		return dist.x;
	}
};
class cF2 : iCellFunc
{
	float result(float2 dist)
	{
		return dist.y;
	}
};
class cF2MinusF1 : iCellFunc
{
	float result(float2 dist)
	{
		return dist.y - dist.x;
	}
};
class cAverage: iCellFunc
{
	float result(float2 dist)
	{
		return (dist.x + dist.y) / 2;
	}
};
class cCrackle: iCellFunc
{
	float result(float2 dist)
	{
		return max(dist.x, dist.y) * dist.y - dist.x;
	}
};
cF1 F1;
cF2 F2;
cF2MinusF1 F2MinusF1;
cAverage Average;
cCrackle Crackle;



float2 w2dHash( float2 p )
{
    p = float2( dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)) );
	return frac(sin(p)*43758.5453);
}
float worley2D(iCellDist cellDistance, iCellFunc cellFunction, float2 p )
{
    float2 n = floor( p );
    float2 f = frac( p );

	float f1 = 8.0;
	float f2 = 8.0;
	
	
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float2 g = float2(i,j);
        float2 o = w2dHash( n + g );
		float2 r = g - f + o;

		//float d = dot(r,r);			// euclidean^2
		float d = cellDistance.get(r);

		if( d<f1 ) 
		{ 
			f2 = f1; 
			f1 = d; 
		}
		else if( d<f2 ) 
		{
			f2 = d;
		}
    }
	
	float c = cellFunction.result(float2(f1, f2));
				c = 1.0 - c;
	
    return c;
}


float3 worley2D_Deriv(iCellDist cellDistance, iCellFunc cellFunction, float2 p)
{
   	float eps = 0.001;
	float f0 = worley2D(cellDistance, cellFunction, p);
	float fx = worley2D(cellDistance, cellFunction, p + float2(eps, 0));
	float fy = worley2D(cellDistance, cellFunction, p + float2(0, eps));
	float2 d = float2(fx - f0, fy - f0) / eps;
	return float3 (f0, d);
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//Worley3D	Return return float for cell noise with various distance metrics & combinations of F1 & F2
///////////////////////////////////////////////////////////////////////////////////////////////////////////


float3 w3dHash( float3 x )
{
	x = float3( dot(x,float3(127.1,311.7, 74.7)),
			  dot(x,float3(269.5,183.3,246.1)),
			  dot(x,float3(113.5,271.9,124.6)));

	return frac(sin(x)*43758.5453123);
}

float worley3D(iCellDist cellDistance, iCellFunc cellFunction, float3 p)
{
	
    float3 whole = floor(p);
    float3 fraction = frac(p);

	float id = 0.0;
    float2 func = 100;
    for( int k=-1; k<=1; k++ )
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        float3 b = float3( float(i), float(j), float(k) );
        float3 r = float3( b ) - fraction + w3dHash( whole + b );
      
    	float dist = cellDistance.get(r);
		
    	if( dist < func.x )
        {
            func = float2( dist, func.x );			
        }
        else if( dist < func.y )
        {
            func.y = dist;
        }
    }

    return  cellFunction.result(func);
}

float4 worley3D_Deriv(iCellDist cellDistance, iCellFunc cellFunction, float3 p)
{
   	float eps = 0.001;
	float f0 = worley3D(cellDistance, cellFunction, p);
	float fx = worley3D(cellDistance, cellFunction, p + float3(eps, 0, 0));
	float fy = worley3D(cellDistance, cellFunction, p + float3(0, eps, 0));
	float fz = worley3D(cellDistance, cellFunction, p + float3(0, 0, eps));
	float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
	return float4 (f0, d);
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
//Noise Types
//////////////////////////////////////////////////////////////////////////////////////////////////

interface iNoiseType 
{
	float n2 (float2 p);
	float3 nd2 (float2 p);
	float n3(float3 p);
	float4 nd3(float3 p);
};
class cPerlin : iNoiseType 
	{
	float n2(float2 p){return perlin2D(p);}
	float3 nd2(float2 p){return perlin2D_Deriv(p);}
	float n3(float3 p){return perlin3D(p);}
	float4 nd3(float3 p){return perlin3D_Deriv(p);}
	};
class cSimplex : iNoiseType 
{
	float n2(float2 p){return simplex2D(p);}
	float3 nd2(float2 p){return simplex2D_Deriv(p);}
	float n3(float3 p){return simplex3D(p);}
	float4 nd3(float3 p){return simplex3D_Deriv(p);}
};
class cFastWorley : iNoiseType 
{
	float n2(float2 p){return fastWorley2D(p);}
	float3 nd2(float2 p){return fastWorley2D_Deriv(p);}
	float n3(float3 p){return fastWorley3D(p);}
	float4 nd3(float3 p){return fastWorley3D_Deriv(p);}
};

// advanced worley dealt with by different signature 


cPerlin Perlin;
cSimplex Simplex;
cFastWorley FastWorley;




//////////////////////////////////////////////////////////////////////////////////////////////////
//Fractal Sum Functions
//////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
//FBM
//////////////////////////////////////////////////////////////////////////////////////////////////

//2D
float fBm(iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += noiseType.n2(p*freq)*amp;
		totalAmp += abs(amp);
		amp *= pers;
		freq *= lacun;
	}
	
	return (sum / totalAmp);
}

float3 fBm_Deriv(iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
{
	float3 sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += noiseType.nd2(p*freq)*amp;
		totalAmp += abs(amp);
		amp *= pers;
		freq *= lacun;
	}
	
	return (sum / totalAmp);
}

//special case for worley noise
float fBm(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) {
		p+= i*27.3;
		sum += worley2D(cellDistance, cellFunction, p*freq)*amp;
		totalAmp += abs(amp);
		amp *= pers;
		freq *= lacun;
	}
	return sum;
}
//special case for worley noise
float3 fBm_Deriv(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
{
	float3 sum = 0;	
	float amp = 1;
	float3 totalAmp = 0;
	for(int i=0; i <= oct; i++) {
		p+= i*27.3;
		sum += worley2D_Deriv(cellDistance, cellFunction, p*freq)*amp;
		totalAmp += abs(amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum / totalAmp;
}

//3D
float fBm(iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += noiseType.n3(p*freq)*amp;
		totalAmp += abs(amp);
		amp *= pers;
		freq *= lacun;
	}
	
	return (sum / totalAmp);
}

float4 fBm_Deriv(iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
{
	float4 sum = 0;	
	float amp = 0.5;
	
	
	for(int i=0; i <= oct; i++) {
		p+= i*27.3;
		sum += noiseType.nd3((p)*freq)*amp;
		freq *= lacun;
		amp *= pers;
	}
	return sum;
}

//special case for worley noise
float fBm(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) {
		p+= i*27.3;
		sum += worley3D(cellDistance, cellFunction, p*freq)*amp;
		totalAmp += abs(amp);
		amp *= pers;
		freq *= lacun;
	}
	return sum;
}
//special case for worley noise
float4 fBm_Deriv(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
{
	float4 sum = 0;	
	float amp = 0.5;
	for(int i=0; i <= oct; i++) {
		p+= i*27.3;
		sum += worley3D_Deriv(cellDistance, cellFunction, p*freq)*amp;
		freq *= lacun;
		amp *= pers;
	}
	return sum;
}

//////////////////////////////////////////////////////////////////////////////////////////////////
//Turbulence
//////////////////////////////////////////////////////////////////////////////////////////////////
//2D
float turbulence(iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += abs(noiseType.n2(p*freq)) * amp ;
		totalAmp += abs(amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum / totalAmp;
} 
float3 turbulence_Deriv (iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = turbulence(noiseType, p, freq, pers, lacun, oct);
	float fx = turbulence(noiseType, p + float2(eps, 0), freq, pers, lacun, oct);
	float fy = turbulence(noiseType, p + float2(0, eps), freq, pers, lacun, oct);
	float2 d = float2(fx - f0, fy - f0) / eps;
	return float3 (f0, d);
   }
//special case for worley noise
float turbulence(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += abs(worley2D(cellDistance, cellFunction, p*freq)) / (freq * amp);
		totalAmp += abs(amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum / totalAmp;
} 
//special case for worley noise
float3 turbulence_Deriv (iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = turbulence(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	float fx = turbulence(cellDistance, cellFunction, p + float2(eps, 0), freq, pers, lacun, oct);
	float fy = turbulence(cellDistance, cellFunction, p + float2(0, eps), freq, pers, lacun, oct);
	float2 d = float2(fx - f0, fy - f0) / eps;
	return float3 (f0, d);
   }


//3D
float turbulence(iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += abs(noiseType.n3(p*freq)) * amp ;
		totalAmp += abs(amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum / totalAmp;
} 
float4 turbulence_Deriv (iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = turbulence(noiseType, p, freq, pers, lacun, oct);
	float fx = turbulence(noiseType, p + float3(eps, 0, 0), freq, pers, lacun, oct);
	float fy = turbulence(noiseType, p + float3(0, eps, 0), freq, pers, lacun, oct);
	float fz = turbulence(noiseType, p + float3(0, 0, eps), freq, pers, lacun, oct);
	float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
	return float4 (f0, d);
   }
//special case for worley noise
float turbulence(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
{
	float sum = 0;	
	float amp = 1;
	float totalAmp = 0;
	
	for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		sum += abs(worley3D(cellDistance, cellFunction, p*freq)) / (freq * amp);
		totalAmp += abs(amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum / totalAmp;
} 
//special case for worley noise
float4 turbulence_Deriv (iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = turbulence(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	float fx = turbulence(cellDistance, cellFunction, p + float3(eps, 0, 0), freq, pers, lacun, oct);
	float fy = turbulence(cellDistance, cellFunction, p + float3(0, eps, 0), freq, pers, lacun, oct);
	float fz = turbulence(cellDistance, cellFunction, p + float3(0, 0, eps), freq, pers, lacun, oct);
	float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
	return float4 (f0, d);
   }
// trying to sum derivitives analyticlly
/*
float4 turbulence_Deriv(iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
{
	float4 sum = float4(0.5, 0,0,0);	
	float amp = 1;
	
	for(int i=0; i <= oct; i++) 
	{
		float4 n = noiseType.nd3(p*freq);
		sum += float4(abs(n.x), n.x>0?1:-1*n.yzw) / (freq * amp);
		freq *= lacun;
		amp *= pers;
	}
	return sum;
} 
*/

//////////////////////////////////////////////////////////////////////////////////////////////////
//Ridge        //TODO: normalize output
//////////////////////////////////////////////////////////////////////////////////////////////////
//2D
float ridge (iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
   {
	float amp = 0.5;
    float signal = 0.0;
    float sum  = 0.;
    float weight = 1.0;
    for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		signal = noiseType.n2(p*freq+1);
        signal = 1 - abs(signal);
        signal *= signal;
        signal *= weight;
        weight = signal * amp;
        weight = saturate (weight);
        sum += signal;
      	freq *= lacun;
		amp *= pers;
     }
	return (sum * 1.25) - 1;
   }

float3 ridge_Deriv (iNoiseType noiseType, float2 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps= 0.001;
	float f0 = ridge(noiseType, p, freq, pers, lacun, oct);
	float fx = ridge(noiseType, p + float2(eps, 0), freq, pers, lacun, oct);
	float fy = ridge(noiseType, p + float2(0, eps), freq, pers, lacun, oct);
	float2 d = float2(fx - f0, fy - f0) / eps;
	return float3 (f0, d);
   }

//special case for worley noise
float ridge (iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
   {
	float amp = 0.5;
    float signal = 0.0;
    float sum  = 0.;
    float weight = 1.0;
    for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		signal = worley2D(cellDistance, cellFunction, p*freq+1);
        signal = 1 - abs(signal);
        signal *= signal;
        signal *= weight;
        weight = signal * amp;
        weight = saturate (weight);
        sum += signal;
      	freq *= lacun;
		amp *= pers;
     }
	return (sum * 1.25) - 1;
   }
//special case for worley noise
float3 ridge_Deriv (iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = ridge(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	float fx = ridge(cellDistance, cellFunction, p + float2(eps, 0), freq, pers, lacun, oct);
	float fy = ridge(cellDistance, cellFunction, p + float2(0, eps), freq, pers, lacun, oct);
	float2 d = float2(fx - f0, fy - f0) / eps;
	return float3 (f0, d);
   }

//3D
float ridge (iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
   {
	float amp = 0.5;
    float signal = 0.0;
    float sum  = 0.;
    float weight = 1.0;
    for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		signal = noiseType.n3(p*freq+1);
        signal = 1 - abs(signal);
        signal *= signal;
        signal *= weight;
        weight = signal * amp;
        weight = saturate (weight);
        sum += signal;
      	freq *= lacun;
		amp *= pers;
     }
	return (sum * 1.25) - 1;
   }

float4 ridge_Deriv (iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps= 0.001;
	float f0 = ridge(noiseType, p, freq, pers, lacun, oct);
	float fx = ridge(noiseType, p + float3(eps, 0, 0), freq, pers, lacun, oct);
	float fy = ridge(noiseType, p + float3(0, eps, 0), freq, pers, lacun, oct);
	float fz = ridge(noiseType, p + float3(0, 0, eps), freq, pers, lacun, oct);
	float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
	return float4 (f0, d);
   }

//special case for worley noise
float ridge (iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
   {
	float amp = 0.5;
    float signal = 0.0;
    float sum  = 0.;
    float weight = 1.0;
    for(int i=0; i <= oct; i++) 
	{
		p+= i*27.3;
		signal = worley3D(cellDistance, cellFunction, p*freq+1);
        signal = 1 - abs(signal);
        signal *= signal;
        signal *= weight;
        weight = signal * amp;
        weight = saturate (weight);
        sum += signal;
      	freq *= lacun;
		amp *= pers;
     }
	return (sum * 1.25) - 1;
   }
//special case for worley noise
float4 ridge_Deriv (iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq, float pers, float lacun, int oct)
   {	
   	float eps = 0.001;
	float f0 = ridge(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	float fx = ridge(cellDistance, cellFunction, p + float3(eps, 0, 0), freq, pers, lacun, oct);
	float fy = ridge(cellDistance, cellFunction, p + float3(0, eps, 0), freq, pers, lacun, oct);
	float fz = ridge(cellDistance, cellFunction, p + float3(0, 0, eps), freq, pers, lacun, oct);
	float3 d = float3(fx - f0, fy - f0, fz - f0) / eps;
	return float4 (f0, d);
   }
// trying to sum derivitives analyticlly
/*
float4 ridge_Deriv (iNoiseType noiseType, float3 p, float freq, float pers, float lacun, int oct)
   {	
	float amp = 0.5;
    float4 signal = 0.0;
    float4 sum  = 0.;
    float weight = 1.0;
    for(int i=0; i <= oct; i++) 
	{
		signal = noiseType.nd3(p*freq+1);
        signal = float4(1 - abs(signal.x), signal.x>0?-1:1*signal.yzw); 
        signal *= signal;
        signal *= weight;
        weight = signal.x * amp;
        weight = saturate (weight);
        sum += signal;
      	freq *= lacun;
		amp *= pers;
     }
	return (sum * 1.25) - 1;
   }
*/

interface iFractalNoise 
{
	//2D Noise methods.  MyNoiseD returns noise as x, noise derivitives as yz
	float Perlin(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float3 PerlinD(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float Simplex(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float3 SimplexD(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float FastWorley(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float3 FastWorleyD(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float3 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	
	//3D Noise methods.  MyNoiseD returns noise as x, noise derivitives as yzw
	float Perlin(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float4 PerlinD(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float Simplex(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float4 SimplexD(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float FastWorley(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float4 FastWorleyD(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
	float4 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3);
};



class cNoise : iFractalNoise
{
	//2D
	float Perlin(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return perlin2D(p*freq);
	}
	float3 PerlinD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return perlin2D_Deriv(p*freq);
	}
	
	float Simplex(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return simplex2D(p*freq);
	}
	float3 SimplexD(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return simplex2D_Deriv(p*freq);
	}
	
	float FastWorley(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fastWorley2D(p*freq);
	}
	float3 FastWorleyD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return fastWorley2D_Deriv(p*freq);
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return worley2D(cellDistance, cellFunction, p*freq);
	}
	float3 WorleyD (iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return worley2D_Deriv(cellDistance, cellFunction, p*freq);
	}
	//3D
	float Perlin(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return perlin3D(p*freq);
	}
	float4 PerlinD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return perlin3D_Deriv(p*freq);
	}
	
	float Simplex(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return simplex3D(p*freq);
	}
	float4 SimplexD(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return simplex3D_Deriv(p*freq);
	}
	
	float FastWorley(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fastWorley3D(p*freq);
	}
	float4 FastWorleyD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return fastWorley3D_Deriv(p*freq);
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return worley3D(cellDistance, cellFunction, p*freq);
	}
	float4 WorleyD (iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return worley3D_Deriv(cellDistance, cellFunction, p*freq);
	}
};

class cFBM : iFractalNoise 
{
	//2D
	float Perlin (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(Perlin, p, freq, pers, lacun, oct);
	}
	float3 PerlinD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(Perlin, p, freq, pers, lacun, oct);
	}
	
	float Simplex (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(Simplex, p, freq, pers, lacun, oct);
	}
	float3 SimplexD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return fBm_Deriv(Simplex, p, freq, pers, lacun, oct);
	}
	
	float FastWorley (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(FastWorley, p, freq, pers, lacun, oct);
	}
	float3 FastWorleyD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(FastWorley, p, freq, pers, lacun, oct);
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	float3 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	}
	
	//3D
	float Perlin (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(Perlin, p, freq, pers, lacun, oct);
	}
	float4 PerlinD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(Perlin, p, freq, pers, lacun, oct);
	}
	
	float Simplex (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(Simplex, p, freq, pers, lacun, oct);
	}
	float4 SimplexD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return fBm_Deriv(Simplex, p, freq, pers, lacun, oct);
	}
	
	float FastWorley (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(FastWorley, p, freq, pers, lacun, oct);
	}
	float4 FastWorleyD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(FastWorley, p, freq, pers, lacun, oct);
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	float4 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return fBm_Deriv(cellDistance, cellFunction, p, freq, pers, lacun, oct);
	}
	
};
class cTurbulence : iFractalNoise 
{
	//2D
	float Perlin(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(Perlin, p, freq, pers, lacun, oct);
	}
	float3 PerlinD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(Perlin, p, freq, pers, lacun, oct); 
	}
	
	float Simplex (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(Simplex, p, freq, pers, lacun, oct);
	}
	float3 SimplexD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(Simplex, p, freq, pers, lacun, oct); 
	}
	
	float FastWorley (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(FastWorley, p, freq, pers, lacun, oct);
	}
	float3 FastWorleyD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(FastWorley, p, freq, pers, lacun, oct); 
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	
	float3 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(cellDistance, cellFunction, p, freq, pers, lacun, oct); 
	}
	
	//3D
	float Perlin(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(Perlin, p, freq, pers, lacun, oct);
	}
	float4 PerlinD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(Perlin, p, freq, pers, lacun, oct); 
	}
	
	float Simplex (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(Simplex, p, freq, pers, lacun, oct);
	}
	float4 SimplexD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(Simplex, p, freq, pers, lacun, oct); 
	}
	
	float FastWorley (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(FastWorley, p, freq, pers, lacun, oct);
	}
	float4 FastWorleyD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(FastWorley, p, freq, pers, lacun, oct); 
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	
	float4 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return turbulence_Deriv(cellDistance, cellFunction, p, freq, pers, lacun, oct); 
	}
};

class cRidge : iFractalNoise
{
	//2D
	float Perlin(float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(Perlin, p, freq, pers, lacun, oct);
	}
	
	float3 PerlinD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge_Deriv(Perlin, p, freq, pers, lacun, oct); // TODO
	}
	
	float Simplex (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(Simplex, p, freq, pers, lacun, oct);
	}
	float3 SimplexD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return ridge_Deriv(Simplex, p, freq, pers, lacun, oct); //TODO
	}
	
	float FastWorley (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(FastWorley, p, freq, pers, lacun, oct);
	}
	float3 FastWorleyD (float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return ridge_Deriv(FastWorley, p, freq, pers, lacun, oct); //TODO
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	
	float3 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float2 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge_Deriv(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}

	//3D
	float Perlin(float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(Perlin, p, freq, pers, lacun, oct);
	}
	
	float4 PerlinD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge_Deriv(Perlin, p, freq, pers, lacun, oct); // TODO
	}
	
	float Simplex (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(Simplex, p, freq, pers, lacun, oct);
	}
	float4 SimplexD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return ridge_Deriv(Simplex, p, freq, pers, lacun, oct); //TODO
	}
	
	float FastWorley (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(FastWorley, p, freq, pers, lacun, oct);
	}
	float4 FastWorleyD (float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
	return ridge_Deriv(FastWorley, p, freq, pers, lacun, oct); //TODO
	}
	
	float Worley(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
	
	float4 WorleyD(iCellDist cellDistance, iCellFunc cellFunction, float3 p, float freq = 1, float pers = 0.98, float lacun =1.97,  int oct = 3)
	{
		return ridge_Deriv(cellDistance, cellFunction,  p, freq, pers, lacun, oct);
	}
};
cNoise Noise;
cFBM FBM;
cTurbulence Turbulence;
cRidge Ridge;
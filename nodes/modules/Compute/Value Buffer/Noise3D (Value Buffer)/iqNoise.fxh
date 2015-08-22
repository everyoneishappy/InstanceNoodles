int iqIcoolfFunc3d2( in int n )
{
    n=(n<<13)^n;
    return (n*(n*n*15731+789221)+1376312589) & 0x7fffffff;
}

float iqCoolfFunc3d2( in int n )
{
    return float(iqIcoolfFunc3d2(n));
}

float iqNoise3f( in float3 p )
{
    int3 ip = int3(floor(p));
    float3 u = frac(p);
    u = u*u*(3.0-2.0*u);

    int n = ip.x + ip.y*57 + ip.z*113;

    float res = lerp(lerp(lerp(iqCoolfFunc3d2(n+(0+57*0+113*0)),
                            iqCoolfFunc3d2(n+(1+57*0+113*0)),u.x),
                        lerp(iqCoolfFunc3d2(n+(0+57*1+113*0)),
                            iqCoolfFunc3d2(n+(1+57*1+113*0)),u.x),u.y),
                    lerp(lerp(iqCoolfFunc3d2(n+(0+57*0+113*1)),
                            iqCoolfFunc3d2(n+(1+57*0+113*1)),u.x),
                        lerp(iqCoolfFunc3d2(n+(0+57*1+113*1)),
                            iqCoolfFunc3d2(n+(1+57*1+113*1)),u.x),u.y),u.z);

    return 1.0 - res*(1.0/1073741824.0);
}

float iqFbm3d( in float3 p )
{
    return 0.5000*iqNoise3f(p*1.0) +
           0.2500*iqNoise3f(p*2.0) +
           0.1250*iqNoise3f(p*4.0) +
           0.0625*iqNoise3f(p*8.0);
}
//@author: Everyoneishappy


// -----------------------------------------------------------------------------
// PARAMETERS:
// -----------------------------------------------------------------------------

//transforms
float4x4 tW: WORLD;        //the models world matrix
float4x4 tV: VIEW;         //view matrix as set via Renderer (EX9)
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tP: PROJECTION;   //projection matrix as set via Renderer (EX9)
float4x4 tWIT: WORLDINVERSETRANSPOSE;


float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
//float3 CamPos = 0;
float KrMin = 0.002;
float Kr = 1;
float FresExp = 5.0;

Texture2D texture2d <string uiname="Fresnel Texture";>;

bool useNormalMap = 0;
Texture2D nTex <string uiname="Normal map";>;

SamplerState Samp <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};

SamplerState Samp2 <string uiname="Sampler State";>
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Wrap;
    AddressV = Wrap;
};

//////////////////////////////////////////////////////////////
float3 NormalMapper( float3 N, float3 V, float3 Nmap, float3 texcoord )
{
    // assume N, the interpolated vertex normal and 
    // V, the view vector (vertex to eye)
    
    Nmap = Nmap * 2 -1;
    //Nmap.y = -Nmap.y;

	//TBN///////////
	    // get edge vectors of the pixel triangle
    float3 dp1 = ddx( -V );
    float3 dp2 = ddy( -V );
    float2 duv1 = ddx( texcoord );
    float2 duv2 = ddy( texcoord );
 
    // solve the linear system
    float3 dp2perp = cross( dp2, N );
    float3 dp1perp = cross( N, dp1 );
    float3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    float3 B = dp2perp * duv1.y + dp1perp * duv2.y;
 
    // construct a scale-invariant frame 
    float invmax = rsqrt( max( dot(T,T), dot(B,B) ) );
    float3x3 TBN = float3x3( T * invmax, B * invmax, N );
	//TBN///////////
	
    
	float3 n = mul (Nmap,  TBN);
	
	return normalize( n);
	
}
//////////////////////////////////////////////////////////////

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
	float4 TexCd : TEXCOORD0;
    float3 NormV: TEXCOORD2;
    float3 ViewDirV: TEXCOORD3;
};

// -----------------------------------------------------------------------------
// VERTEXSHADERS
// -----------------------------------------------------------------------------

vs2ps VS(
    float4 PosO: POSITION,
    float3 NormO: NORMAL,
    float4 TexCd : TEXCOORD0)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;


    
    //normal in view space
    Out.NormV = normalize(mul(mul(NormO, (float3x3)tWIT),(float3x3)tV).xyz);
	
	Out.TexCd =  mul(TexCd, tTex);

    //position (projected)
    Out.PosWVP  = mul(PosO, tWVP);

    Out.ViewDirV = -normalize(mul(PosO, tWV));
    return Out;
}

// -----------------------------------------------------------------------------
// PIXELSHADERS:
// -----------------------------------------------------------------------------

float Alpha <float uimin=0.0; float uimax=1.0;> = 1;

float4 PS(vs2ps In): SV_Target
{
//	float Vn = normalize(CamPos - In.PosWVP);
	float3 n;
	if (useNormalMap) 
	{
		float3 Nmap = nTex.Sample(Samp2, In.TexCd); 
		n = NormalMapper( In.NormV, In.NormV, Nmap, In.TexCd );
	}
	else {n = In.NormV;}
	
	float vdn = dot(In.ViewDirV,n);
	float fres = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);
	
    float4 col = fres;
    col.a = Alpha;
    

    return col;
}

float4 PSt(vs2ps In): SV_Target
{

	float3 n;
	if (useNormalMap) 
	{
		float3 Nmap = nTex.Sample(Samp2, In.TexCd); 
		n = NormalMapper( In.NormV, In.NormV, Nmap, In.TexCd );
	}
	else {n = In.NormV;}
	
	float vdn = dot(In.ViewDirV,n);
	float fres = KrMin + (Kr-KrMin) * pow(1-abs(vdn),FresExp);
	
    float4 col = texture2d.Sample(Samp, fres);
    col.a *= Alpha;
    

    return col;
}


// -----------------------------------------------------------------------------
// TECHNIQUES:
// -----------------------------------------------------------------------------
technique10 Fresnel
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}

technique10 FresnelTexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PSt() ) );
	}
}

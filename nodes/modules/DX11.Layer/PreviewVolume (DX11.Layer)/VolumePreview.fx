//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

Texture2D texture2d <string uiname="Texture";>;
Texture3D texVOL <string uiname="Volume";>;

SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
	AddressW = CLAMP;
};
SamplerState g_samPoint : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
	AddressW = CLAMP;
};
 
cbuffer cbPerDraw : register( b0 )
{
	float4x4 tVP : VIEWPROJECTION;
	float4x4 tTex <string uiname="Texture Transform";>;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 

};


cbuffer cbPerObj : register( b1 )
{
	float4x4 tW : WORLD;

};

struct VS_IN
{
	float4 PosO : POSITION;
	float4 TexCd : TEXCOORD0;

};

struct vs2ps
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
};

vs2ps VS(VS_IN input)
{
    vs2ps Out = (vs2ps)0;
    Out.PosWVP  = mul(input.PosO,mul(tW,tVP));
    Out.TexCd = mul(input.TexCd, tTex);
    return Out;
}



float Z=0;
bool Cut=0;
float Threshold=0;
int SliceCount=1;
float4 PS_Normals (vs2ps In): SV_Target
{
    float4 col = texture2d.Sample(g_samLinear,In.TexCd.xy);
	
	col = texVOL.Sample(g_samLinear,float3(In.TexCd.xy,Z)).x;
	if(Cut)col=col.x<Threshold;
	//if(Cut)col=abs(col.x-Threshold)<.002;
	//if(col.x==0)discard;
	float2 e=float2(1./SliceCount,0);
	
	float3 p=float3(In.TexCd.xy,Z);
	//p+=sin(p.yzx*16)*.04;
	
	if(texVOL.SampleLevel(g_samLinear,p,0).x>Threshold)discard;
	float3 n=normalize(float3(
	texVOL.SampleLevel(g_samLinear,p-e.xyy,0).x,
	texVOL.SampleLevel(g_samLinear,p-e.yxy,0).x,
	texVOL.SampleLevel(g_samLinear,p-e.yyx,0).x
	)
	-texVOL.SampleLevel(g_samLinear,p-e.yyy,0).x
	);
	col.rgb=n*.5+.5;;
	col.a*=Alpha;
	
    return col;
}

float4 PS_Raw (vs2ps In): SV_Target
{

	float4 col = texVOL.Sample(g_samLinear,float3(In.TexCd.xy,Z)).x;
	if(Cut)col=col.x<Threshold;
	float3 p=float3(In.TexCd.xy,Z);

	if(texVOL.SampleLevel(g_samLinear,p,0).x>Threshold)discard;

	col = col * .5+.5;
	col.a*=Alpha;
	
    return col;
}





technique10 SurfaceNormals
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Normals() ) );
	}
}

technique10 Raw
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS_Raw() ) );
	}
}




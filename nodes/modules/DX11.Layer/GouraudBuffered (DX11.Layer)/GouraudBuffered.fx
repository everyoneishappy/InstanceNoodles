#include "..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float> iidb;


float4x4 tVP : VIEWPROJECTION;

StructuredBuffer<float4x4>bTransform;
float4x4 tW : WORLD;
float4x4 tV: VIEW;
float4x4 tWIT: WORLDINVERSETRANSPOSE;
float4x4 tWV: WORLDVIEW;

float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
float lPower <String uiname="Power"; float uimin=3.0;> = 25.0;     

float4 ambDefault <bool color=true;String uiname="Ambient Default XYZW";> = {0.15, 0.15, 0.15, 1};
StructuredBuffer<float4> ambBuffer;

float4 diffDefault <bool color=true;String uiname="Diffuse Default XYZW";> = {0.85, 0.85, 0.85, 1};
StructuredBuffer<float4> diffBuffer;

float4 specDefault <bool color=true;String uiname="Specular Default XYZW";> = {0.35, 0.35, 0.35, 1};
StructuredBuffer<float4> specBuffer;

iGeomIndex ColorIndexing <string linkclass="Instance,Primitive,Vertex";>;


Texture2DArray tex <string uiname="Texture";>;
SamplerState linearSampler 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

float4x4 tTex <string uiname="Texture Transform"; bool uvspace=true; >;
StructuredBuffer<float4x4>sbTexTransform;

struct vsInput
{
	float4 PosO : POSITION;
	float4 NormO : NORMAL;
	float4 TexCd : TEXCOORD0;
	uint vid : SV_VertexID ;

};

struct psInput
{
    float4 PosWVP: SV_POSITION;
    float4 TexCd: TEXCOORD0;
	float4 Ambient : COL0;
	float4 Diffuse: COLOR1;
    float4 Specular: COLOR2;
	uint iid : IID;
};




psInput VS(vsInput input)
{
    psInput output;
	output.iid = iidb[input.vid];
    output.PosWVP  = mul(input.PosO,mul(bLoad(bTransform, tW, output.iid) ,tVP));
	//output.PosWVP  = mul(input.PosO,mul(bTransform[output.iid] ,tVP));
    //output.TexCd = input.TexCd;

	uint colID = ColorIndexing.Get(iidb[input.vid], floor(input.vid/3), input.vid );
	output.Ambient = bLoad(ambBuffer, ambDefault, colID);
	
	float4 lDiff = bLoad(diffBuffer, diffDefault, colID);
	float4 lSpec = bLoad(specBuffer, specDefault, colID);


	output.TexCd = mul(input.TexCd, bLoad(sbTexTransform, tTex, output.iid));
	
	    //inverse light direction in view space
    float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);

    //normal in view space
    float3 NormV = normalize(mul(mul(input.NormO.xyz, (float3x3)tWIT),(float3x3)tV).xyz);
	
    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.PosO, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;
	
	output.Diffuse = diff + output.Ambient;
    output.Specular = spec;
	
    return output;
}


float4 PS(psInput input): SV_Target
{
    float4 col = input.Diffuse + input.Specular;
    return col;
}

float4 PStex(psInput input): SV_Target
{
	uint texCount, dummy;	
	tex.GetDimensions(dummy,dummy,texCount);
   	float4 col = tex.Sample(linearSampler,float3(input.TexCd.xy,input.iid % texCount));
	col.rgb *= input.Diffuse.xyz + input.Specular.xyz;
    return col;
}


technique10 Constant
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PS() ) );
	}
}

technique10 ConstantTextured
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_5_0, VS() ) );
		SetPixelShader( CompileShader( ps_5_0, PStex() ) );
	}
}




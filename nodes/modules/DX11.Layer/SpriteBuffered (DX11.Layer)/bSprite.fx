#include "..\..\Common\InstanceNoodles.fxh"

StructuredBuffer<float3> sbPos;
StructuredBuffer<float3> sbVel;
float TailLength = 1;
float MaxVelLength = 2;

StructuredBuffer<float> sbSize;
float defaultSize = 1;


StructuredBuffer<float4> sbColor;
float4 defaultColor <bool color = true; > = { 1.0,1.0,1.0,1.0 };

Texture2DArray tex0 <string uiname = "Texture"; >;
SamplerState s0 <string uiname = "Sampler"; >
{
	Filter = MIN_MAG_MIP_LINEAR; AddressU = CLAMP; AddressV = CLAMP;
};

bool circleCut, alphaCut;
float AlphaDiscard = 0.2;

cbuffer cbControls:register(b0) {
	float4x4 tVP:VIEWPROJECTION;
	float4x4 tVI:VIEWINVERSE;
	float4x4 tW:WORLD;
};



struct VS_IN {
	uint iv:SV_VertexID;
};

struct VS_OUT {
	float4 PosWVP:SV_POSITION;
	float2 TexCd:TEXCOORD0;
	float4 PosW:TEXCOORD1;
	float Size : TEXCOORD2;
	float4 Color:COLOR0;
	uint iid : IID;

};

struct VS_OUTvel {
	float4 PosWVP:SV_POSITION;
	float2 TexCd:TEXCOORD0;
	float4 PosW:TEXCOORD1;
	float Size : TEXCOORD2;
	float4 Color:COLOR0;
	uint iid : IID;
	float3 vel : TEXCOORD3;

};

VS_OUT VS(VS_IN In) {
	VS_OUT Out = (VS_OUT)0;

	// get buffer count
	uint sCount, cCount, texCount, dummy;	
	sbSize.GetDimensions(sCount,dummy);
	sbColor.GetDimensions(cCount,dummy);
	tex0.GetDimensions(dummy,dummy,dummy,texCount,dummy);
	// set default value for buffer if empty
	float size = defaultSize;
	float4 color = bLoad(sbColor, defaultColor, In.iv);
	//float4 color = defaultColor; 
	if(sCount>0) size = sbSize[In.iv % sCount] * defaultSize;
	//if(cCount>0) color = sbColor[In.iv % cCount];
	
	float3 p = sbPos[In.iv];

	float4 PosW = mul(float4(p, 1), tW);
	Out.PosW = PosW;
	Out.PosWVP = mul(PosW, tVP);
	//Out.TexCd = 0;
	Out.Size = size;
	Out.Color = color;
	Out.iid = In.iv%texCount;
	return Out;
}

VS_OUTvel VSvel(VS_IN In) {
	VS_OUTvel Out = (VS_OUTvel)0;

	uint sCount, cCount, texCount, dummy;	
	sbSize.GetDimensions(sCount,dummy);
	sbColor.GetDimensions(cCount,dummy);
	tex0.GetDimensions(dummy,dummy,dummy,texCount,dummy);
	// set default value for buffer if empty
	float size = defaultSize;
	float4 color = defaultColor; 
	if(sCount>0) size = sbSize[In.iv % sCount] * defaultSize;
	if(cCount>0) color = sbColor[In.iv % cCount];
	
	float3 p = sbPos[In.iv];

	float4 PosW = mul(float4(p, 1), tW);
	Out.PosW = PosW;
	Out.PosWVP = mul(PosW, tVP);
	//Out.TexCd = 0;
	Out.Size = size;
	Out.Color = color;
	float3 velocity = sbVel[In.iv];
	velocity *= step(length(velocity),MaxVelLength);
	Out.vel = velocity;
	Out.iid = In.iv%texCount;
	return Out;
}

float3 g_positions[4]:IMMUTABLE = { { -1,1,0 },{ 1,1,0 },{ -1,-1,0 },{ 1,-1,0 } };
float2 g_texcoords[4]:IMMUTABLE = { { 0,0 },{ 1,0 },{ 0,1 },{ 1,1 } };

[maxvertexcount(4)]
void gsSPRITE(point VS_OUT In[1], inout TriangleStream<VS_OUT> SpriteStream)
{
	VS_OUT Out = In[0];
	Out.iid = In[0].iid;
	for (int i = 0; i<4; i++) {
		Out.TexCd = g_texcoords[i].xy;
		Out.PosWVP = mul(float4(In[0].PosW.xyz + In[0].Size*mul(float4(g_positions[i].xyz, 1), (float3x3)tVI), 1), tVP);
		SpriteStream.Append(Out);
	}

}

[maxvertexcount(4)]
void gsSPRITETail(point VS_OUTvel In[1], inout TriangleStream<VS_OUTvel> SpriteStream, in uint pi : SV_PrimitiveID)
{
	VS_OUTvel Out = In[0];
	
	float3 p=In[0].PosW.xyz;
	float3 vel=In[0].vel;
	float3 camPos=mul(float4(0,0,0,1),tVI).xyz;
	float3 View = p - camPos;
	View = normalize(View);
	float3 upVector = normalize(vel+.0000001*float3(0,1,0));//float3(1, 1, 0);
	float3 rightVector = normalize(cross(View, upVector));
	
	
	float size =In[0].Size;
	
	upVector*=size;
	upVector*=1+TailLength*40*(length(vel));
	rightVector*=size;
	Out.TexCd=float2(1,1);
    Out.PosWVP = mul(float4(p+rightVector+upVector,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(0,1);
	Out.PosWVP = mul(float4(p-rightVector+upVector,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(1,0);
	Out.PosWVP = mul(float4(p+rightVector-upVector*1,1.0),tVP);  
    SpriteStream.Append(Out);
	Out.TexCd=float2(0,0);
	Out.PosWVP = mul(float4(p-rightVector-upVector*1,1.0),tVP);  
    SpriteStream.Append(Out);
	SpriteStream.RestartStrip();
	

}



float4 PS(VS_OUT In) :SV_Target
{
	
	if (circleCut && length(In.TexCd.xy-.5)>0.5) discard;
	
	float4 c = tex0.Sample(s0, float3(In.TexCd.xy, In.iid));
	
	if (alphaCut && c.a < AlphaDiscard) discard;
	
	c = c*In.Color;
	return c;
}

technique10 Sprite {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VS()));
		SetGeometryShader(CompileShader(gs_5_0, gsSPRITE()));
		SetPixelShader(CompileShader(ps_5_0, PS()));
	}
}

technique10 SpriteTailed {
	pass P0 {
		SetVertexShader(CompileShader(vs_5_0, VSvel()));
		SetGeometryShader(CompileShader(gs_4_0, gsSPRITETail()));
		SetPixelShader(CompileShader(ps_4_0, PS()));
	}
}



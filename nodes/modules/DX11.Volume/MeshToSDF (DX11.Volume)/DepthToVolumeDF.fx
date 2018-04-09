RWTexture3D<float> RWDistanceVolume : BACKBUFFER;

float3 InvVolumeSize : INVTARGETSIZE;
float3 VolumeSize : TARGETSIZE;


Texture2D texDEPTH <string uiname="Depth Buffer";>;
SamplerState s0:IMMUTABLE {Filter=MIN_MAG_MIP_POINT;AddressU=CLAMP;AddressV=CLAMP;};

float4x4 tVP:VIEWPROJECTION;
float4x4 tW:WORLD;
float4x4 tV:VIEW;
float4x4 tP:PROJECTION;
float4x4 tWI:WORLDINVERSE;
float4x4 tVI:VIEWINVERSE;
float4x4 tPI:PROJECTIONINVERSE;

float3 r3d(float3 p,float3 z){z*=acos(-1)*2;float3 x=cos(z),y=sin(z);return mul(p,float3x3(x.y*x.z+y.x*y.y*y.z,-x.x*y.z,y.x*x.y*y.z-y.y*x.z,x.y*y.z-y.x*y.y*x.z,x.x*x.z,-y.y*y.z-y.x*x.y*x.z,x.x*y.y,y.x,x.x*x.y));}

float f(float3 p)
{
	float d=99999;
	//p=r3d(p,1.3*(length(p)));
	d=min(d,length(p+sin(p.yzx*14+sin(p.zxy*34)*.4)*.15)-.25);
	//d=p.y;
	//d+=sin(length(sin(p.xz*8))*8)*.05;
	
	//d=(d)-.14;
	//d=max(d,(.4-length((frac(r3d(p,.4)*14)-.5)))/14);
	//d-=.005;

	return d;
}
#define IS_ORTHO(P) (round(P._34)==0&&round(P._44)==1)

float4 UVZtoVIEW(float2 UV,float z){
	if(IS_ORTHO(tP))return mul(float4(UV.x*2-1,1-2*UV.y,z,1.0),tPI);
	float4 p=mul(float4(UV.x*2-1,1-2*UV.y,0,1.0),tPI);
	float ld = tP._43 / (z - tP._33);
	p=float4(p.xy*ld,ld,1.0);
	return p; 
}
float4 UVZtoWORLD(float2 UV,float z){
	return mul(UVZtoVIEW(UV,z),tVI); 
}
bool Reset=0;
[numthreads(8, 8, 8)]
void CSf( uint3 ti : SV_DispatchThreadID)
{ 
	float3 p = ti;
	p *= InvVolumeSize;
	p -= 0.5f;
	p = mul(float4(p,1),tWI).xyz;
	//p = mul(float4(p,1),tV).xyz;
	//RWDistanceVolume[ti] = f(p);
	float4 pv=mul(float4(p.xyz,1),tV);
	float4 pp=mul(pv,tP);
	float2 uv=pp.xy/pp.w*float2(1,-1)*.5+.5;
	float d=texDEPTH.SampleLevel(s0,uv,0).x;
	float ld=tP._43/(d-tP._33);
	if(IS_ORTHO(tP))ld=(d-tP._43)/tP._33;
	float sg=sign(pv.z-ld);
	
	float4 pw=UVZtoWORLD(uv,d);
	float df=RWDistanceVolume[ti];
	float neg=df<0;
	df=abs(df);
	if(Reset)df=9999999;
	//if(Reset){df=9999999;RWDistanceVolume[ti]=df;return;}
	//if(df>99999&&d==1){RWDistanceVolume[ti]=df;return;}
	if(pv.z<ld)neg=0;
	if(df>99999)neg=1;
	//if(d!=1&&init)df=-df;
	
	//if(d!=1)df=pv.z-ld;
	//if(d!=1)df=-length(p-pw.xyz)*sg;
	if(d!=1)df=min(df,length(p-pw.xyz));
	if(neg)df=-df;
	RWDistanceVolume[ti]=df;
	//return;
	/*
	float d=0;
	for(int i=0;i<5;i++){
		for(int j=0;j<5;j++){
			for(int k=0;k<5;k++){
				d+=f(p+(float3(i,j,k)-2)*.006);
			}
		}
	}
	RWDistanceVolume[ti] = d/9.;
	//*/
	//Do a simple distance field
	
}

technique11 Out
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSf() ) );
	}
}





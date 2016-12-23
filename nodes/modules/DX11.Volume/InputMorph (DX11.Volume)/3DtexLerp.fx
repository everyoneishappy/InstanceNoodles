#include <packs\InstanceNoodles\nodes\modules\Common\InstanceNoodles.fxh>
RWTexture3D<float> RWDistanceVolume : BACKBUFFER;
Texture3D<float> volA, volB;
float lerpValue = 0;
StructuredBuffer<float> lerpBuffer;

[numthreads(8, 8, 8)]
void CS_Lerp( uint3 ti : SV_DispatchThreadID)
{ 

	uint id = ti.x*ti.y*ti.z;
	float l = bLoad(lerpBuffer, lerpValue, id);
	RWDistanceVolume[ti] = lerp(volA[ti], volB[ti], l);
}



technique11 Lerp {pass P0{SetComputeShader( CompileShader( cs_5_0, CS_Lerp() ) );}}

interface iMap
{
   float map(float Input, float InMin, float InMax, float OutMin, float OutMax);
};

class cMapFloat : iMap
{
		float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
		{
			float range = InMax - InMin;
			float normalized = (Input - InMin) / range;	
	    	return OutMin + normalized * (OutMax - OutMin);
		}
	
};

class cMapClamp : iMap
{
	float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
		{
			float range = InMax - InMin;
			float normalized = (Input - InMin) / range;	
	    	float output = OutMin + normalized * (OutMax - OutMin);
			float minV = min(OutMin,OutMax);
			float maxV = max(OutMin, OutMax);
	   		output = min(max(output, minV), maxV);
			return output ;
		}
};


class cMapWrap : iMap
{
	float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
		{
		float range = InMax - InMin;
		float normalized = (Input - InMin) / range;	
	    float output = OutMin + normalized * (OutMax - OutMin);
        if (normalized < 0)
	    normalized = 1 + normalized;
		return  OutMin + (normalized % 1) * (OutMax - OutMin);
		}
};

class cMapMirror : iMap
{
	float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
		{
			float range = InMax - InMin;
			float normalized = (Input - InMin) / range;	
			normalized = 1-2*abs(frac(normalized*.5)-.5);
	    	float output = OutMin + (normalized % 1) * (OutMax - OutMin);

			return output;
		}
};


cMapFloat MapFloat;
cMapClamp MapClamp;
cMapWrap MapWrap;	
cMapMirror MapMirror;

iMap MapType <string linkclass="MapFloat,MapClamp,MapWrap,MapMirror";>;

float map(float Input, float InMin, float InMax, float OutMin, float OutMax)
{
	return MapType.map( Input,  InMin,  InMax,  OutMin,  OutMax);
}

float2 map(float2 Input, float2 InMin, float2 InMax, float2 OutMin, float2 OutMax)
{
	float2 vec;
	vec.x = MapType.map( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = MapType.map( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	return vec;
}

float3 map(float3 Input, float3 InMin, float3 InMax, float3 OutMin, float3 OutMax)
{
	float3 vec;
	vec.x = MapType.map( Input.x,  InMin.x,  InMax.x,  OutMin.x,  OutMax.x);
	vec.y = MapType.map( Input.y,  InMin.y,  InMax.y,  OutMin.y,  OutMax.y);
	vec.z = MapType.map( Input.z,  InMin.z,  InMax.z,  OutMin.z,  OutMax.z);
	return vec;
}



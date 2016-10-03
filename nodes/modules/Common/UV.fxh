
#define TWOPI 6.28318531
#define PI 3.14159265
//UV Interface and Classes definitions

//Usage:////////////////////////////////////////////////////////////////////////////////////////////////
//iUVMode uvMode <string linkclass="UVmap,PlanarXY,PlanarXZ,PlanarZY,Cubic,Spherical,Cylindrical";>;
//
//uvMode.Map(pos,norm,uv);
////////////////////////////////////////////////////////////////////////////////////////////////////////
interface iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv);
};

class cUVmap : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv) { return uv; }
}; 

class cPlanarXY : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv) { return float2(pos.x, -pos.y)+.5; }
}; 

class cPlanarXZ : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv) { return float2(pos.x, -pos.z)+.5; }
}; 

class cPlanarZY : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv) { return float2(pos.z, -pos.y)+.5; }
};

class cCubic  : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv)
	{
		norm = float3(abs(norm.x), abs(norm.y), abs(norm.z));
		if (norm.x > norm.y && norm.x > norm.z)
		return float2(pos.z, -pos.y)+.5;
		else if (norm.y > norm.x && norm.y > norm.z)
		return float2(pos.x, -pos.z)+.5;
		else return float2(pos.x, -pos.y)+.5;
	}
};

class cSpherical : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv)
	{ 
		
		float2 result;
		float r;
		r = norm.x * norm.x + norm.y * norm.y + norm.z * norm.z;

	
		if (r > 0)
		{
			r = sqrt(r);
			float p, y;
			p = asin(norm.y/r) / TWOPI;
			y = 0;
			if (norm.z != 0) y = atan2(-norm.x, -norm.z);
			else if (norm.x > 0) y = -PI / 2;
       	 	else y = PI / 2;
			y /=  TWOPI;
			result = float2(-y,-(p+.25)*2);		
		}
		else result = 0;
		return result;
	}
};

class cCylindrical : iUVMode
{
   float2 Map(float3 pos, float3 norm, float2 uv)
	{
		uv.y = -pos.y-.5;
		if (length(pos) > 0)
		{
		if (pos.z != 0)  uv.x = atan2(pos.x, -pos.z);
		else if (pos.x > 0) uv.x = -PI / 2;
        else uv.x = PI / 2;
		uv.x /=  TWOPI;
		}
		else uv.x = 0;
		return uv;
	
	}
};

cUVmap UVmap;
cPlanarXY PlanarXY;
cPlanarXZ PlanarXZ;
cPlanarZY PlanarZY;
cCubic Cubic;
cSpherical Spherical;
cCylindrical Cylindrical;
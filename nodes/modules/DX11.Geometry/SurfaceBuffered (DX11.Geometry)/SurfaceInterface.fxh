#define TWOPI 6.28318531
#define PI 3.14159265f
#define HALFPI PI * 0.5f
float Amount = 1;
float2 Offset = 0;
float2 Scale = 1;


interface iSurface
{
   float3 Get(float u, float v, float4 p);
};

class cFolium : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * (2 * v/ PI - tanh(v));
		float y = cos(u + TWOPI / 3) / cosh(v);
		float z = cos(u - TWOPI / 3) / cosh(v);
		return float3(x, y, z);
	}
};
cFolium Folium;

class cApple : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * (4 + 3.8 * cos(v));
		float y = sin(u) * (4 + 3.8 * cos(v));
		float z = (cos(v) + sin(v) - 1) * (1 + sin(v)) * log(1 - PI*v / 10) + 7.5 * sin(v);
		return float3(x, y, z);
	}	
};
cApple Apple;

class cAstroidalEllipsoid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = pow(cos(u)*cos(v),3);
		float y = pow(sin(u)*cos(v),3);
		float z = pow(sin(v),3);
		return float3(x, y, z);
	}	
};
cAstroidalEllipsoid AstroidalEllipsoid;

class cBentHorns : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 + cos(u)) * (v/3 - sin(v));
		float y = (2 + cos(u - TWOPI/3)) * (cos(v) - 1);
		float z = (2 + cos(u + TWOPI/3)) * (cos(v) - 1);
		return float3(x, y, z);
	}	
};
cBentHorns BentHorns;

class cBohemianDome : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * cos(u);
		float y = p.x * sin(u) + p.y * cos(v);
		float z = p.z * sin(v);
		return float3(x, y, z);
	}	
};
cBohemianDome BohemianDome;

class cBour : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = pow(u,p.x-1)* cos((p.x-1)*v)/(2 *(p.x-1)) - pow(u,p.x+1)* cos((p.x+1) *v)/(2 *(p.x+1));
   		float y = pow(u,p.x-1)* sin((p.x-1)*v)/(2 *(p.x-1)) + pow(u,p.x+1)* sin((p.x+1)* v)/(2* (p.x+1));
    	float z = pow(u,p.x) * cos(p.x * v) / p.x;
    	return float3(x, y, z);
	}	
};
cBour Bour;

class cBow : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 + p.x * sin(TWOPI * u)) * sin(2 * TWOPI * v);
		float y = (2 + p.x * sin(TWOPI * u)) * cos(2 * TWOPI * v);
		float z = p.x * cos(TWOPI * u) + 3 * cos(TWOPI * v);
		return float3(x, y, z);
	}	
};
cBow Bow;

class cCatalan : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (u - cosh(v) * sin(u));
		float y = p.x * (1 - cosh(v) * cos(u)) ;
		float z = -4 * p.x * sin(u/2) * sinh(v/2) ;
		return float3(x, y, z);
	}	
};
cCatalan Catalan;

class cCatenoid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * cosh(v/p.x) * cos(u);
		float y = p.x * cosh(v/p.x) * sin(u) ;
		float z = v;
		return float3(x, y, z);
	}	
};
cCatenoid Catenoid;

class cCone : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (u - cosh(v) * sin(u));
		float y = p.x * (1 - cosh(v) * cos(u)) ;
		float z = -4 * p.x * sin(u/2) * sinh(v/2) ;
		return float3(x, y, z);
	}	
};
cCone Cone;

class cCorkscrew : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * cos(u) * cos(v);
		float y = p.x * sin(u) * cos(v);
		float z = p.x * sin(v) + p.y * u;
		return float3(x, y, z);
	}	
};
cCorkscrew Corkscrew;

class cCresent : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 + sin(TWOPI * u) * sin(TWOPI * v)) * sin(3 * PI * v);
		float y = (2 + sin(TWOPI * u) * sin(TWOPI * v)) * cos(3 * PI * v);
		float z = cos(TWOPI * u) * sin(TWOPI * v) + 4 * v - 2;
		return float3(x, y, z);
	}	
};
cCresent Cresent;

class cCrossCap : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * sin(2*v);
		float y = sin(u) * sin(2*v);
		float z = pow(cos(v), 2) - pow(cos(u),2) * pow (sin(v),2);
		return float3(x, y, z);
	}	
};
cCrossCap CrossCap;

class CDini : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * cos(u) * sin(v);
		float y = p.x * sin(u) * sin(v) ;
		float z = p.x * (cos(v) + log(tan(v/2))) + p.y * u ;
		return float3(x, y, z);
	}	
};
CDini Dini;

class cDoubleCone : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = v * cos(u) ;
		float y = (v - 1) * cos(u + TWOPI/3) ;
		float z = (1 - v ) * cos(u - TWOPI/3) ;
		return float3(x, y, z);
	}	
};
cDoubleCone DoubleCone;

class cEight : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * sin(2*v);
		float y = sin(u) * sin(2*v);
		float z = sin(v);
		return float3(x, y, z);
	}	
};
cEight Eight;

class cEllipticTorus : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (p.x + cos(v)) * cos(u);
		float y = (p.x + cos(v)) * sin(u) ;
		float z = sin(v) + cos(v);
		return float3(x, y, z);
	}	
};
cEllipticTorus EllipticTorus;

class cEnnepers : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = u - pow(u,3)/3 + u * pow(v,2);
		float y = v - pow(v,3)/3 + v * pow(u,2);
		float z = pow(u,2) - pow(v,2);
		return float3(x, y, z);
	}	
};
cEnnepers Ennepers;

class cFigure8Torus : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (p.x + cos(v)) * cos(u);
		float y = (p.x + cos(v)) * sin(u) ;
		float z = sin(v) + cos(v);
		return float3(x, y, z);
	}	
};
cFigure8Torus Figure8Torus;

class cFish : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (cos(u) - cos(2*u)) * cos(v) / 4;
		float y = (sin(u) - sin(2*u)) * sin(v) / 4 ;
		float z = cos(u) ;
		return float3(x, y, z);
	}	
};
cFish Fish;

class cHandkerchief : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = u;
		float y = v;
		float z = pow(u,3) / 3 + u * pow(v,2) + p.x * (pow(u,2) - pow(v,2));
		return float3(x, y, z);
	}	
};
cHandkerchief Handkerchief;

class cHelicoid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * v * cos(u);
   		float y = p.x * v * sin(u) ;
   		float z = u;
    	return float3(x, y, z);
	}	
};
cHelicoid Helicoid;

class cHenneburg : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = 2 * sinh(u) * cos(v) - 2 * sinh(3*u) * cos(3*v)/3;
		float y = 2 * sinh(u) * sin(v) + 2 * sinh(3*u) * sin(3*v)/3;
		float z = 2 * cosh(2*u) * cos(2*v);
		return float3(x, y, z);
	}	
};
cHenneburg Henneburg;

class cHorn : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 + u * cos(v)) * sin(TWOPI * u);
		float y = (2 + u * cos(v)) * cos(TWOPI * u) + 2 * u ;
		float z = u * sin(v);
		return float3(x, y, z);
	}	
};
cHorn Horn;

class cHyperboloid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * pow((1 + pow(u,2)),0.5) * cos(v);
		float y = p.y * pow((1 + pow(u,2)),0.5) * sin(v);
		float z = p.z * (u);
		return float3(x, y, z);
	}	
};
cHyperboloid Hyperboloid;

class cHyperHelicoid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (sin(v) * cos(p.y * u)) / (1 + cosh(u) * cosh(v));
		float y = p.x * (sin(v) * sin(p.y * u)) / (1 + cosh(u) * cosh(v));
		float z = (cosh(v) * sinh(u)) / (1 + cosh(u) * cosh(v));
		return float3(x, y, z);
	}	
};
cHyperHelicoid HyperHelicoid;

class cJet : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (1 - cosh(u)) * sin(u) * cos(v)/2;
		float y = (1 - cosh(u)) * sin(u) * sin(v)/2;
		float z = cosh(u) ;
		return float3(x, y, z);
	}	
};
cJet Jet;

class cKidney : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * (3*cos(v) - cos(3*v));
		float y = sin(u) * (3*cos(v) - cos(3*v));
		float z = 3 * sin(v) - sin(3*v);
		return float3(x, y, z);
	}	
};
cKidney Kidney;

class cKleinBottle : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
	float r = 4 * (1 - cos(u) / 2);
	float x = 6 * cos(u) * (1 + sin(u)) + r * cos(v + PI);
	float y = 16 * sin(u);
	float z = r * sin(v);     
	return float3(x, y, z);
	}	
};
cKleinBottle KleinBottle;

class cKleinCycloid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u/p.z) * cos(u/p.y) * (p.x + cos(v)) + sin(u/p.y) * sin(v) * cos(v);
		float y = sin(u/p.z) * cos(u/p.y) * (p.x + cos(v)) + sin(u/p.y) * sin(v) * cos(v);
		float z = -sin(u/p.y) * (p.x + cos(v)) + cos(u/p.y) * sin(v) * cos(v);
		return float3(x, y, z);
	}	
};
cKleinCycloid KleinCycloid;

class cKuen : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 * (cos(v) + (v * sin(v))) * sin(u)) / (1 + pow(v,2) * pow(sin(u),2));
		float y = (2 * (sin(v) - (v * cos(v))) * sin(u)) / (1 + pow(v,2) * pow(sin(u),2));
		float z = (log(tan(u/2)) + ((2*cos(u)))) / (1 + pow(v,2) * pow(sin(u),2));
		return float3(x, y, z);
	}	
};
cKuen Kuen;

class cLemniscape : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float cosvSqrtAbsSin2u = cos(v)*sqrt(abs(sin(2*u)));
    	float x = cosvSqrtAbsSin2u*cos(u);
    	float y = cosvSqrtAbsSin2u*sin(u);
   		float z = pow(x,2) - pow(y,2) + 2 * x * y * pow(tan(v),2);
   		return float3(x, y, z);
	}	
};
cLemniscape Lemniscape;

class cLimpetTorus : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) / (sqrt(2) + sin(v));
		float y = sin(u) / (sqrt(2) + sin(v));
		float z = 1 / (sqrt(2) + cos(v));
		return float3(x, y, z);
	}	
};
cLimpetTorus LimpetTorus;

class cMaedersOwl : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = v * cos(u) - 0.5 * pow(v,2) * cos(2 * u);
		float y = - v * sin(u) - 0.5 * pow(v,2) * sin(2 * u);
		float z = 4 * pow(v,1.5) * cos(3 * u / 2) / 3;
		return float3(x, y, z);
	}	
};
cMaedersOwl MaedersOwl;

class cMoebius : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) + v * cos(u/2) * cos(u);
		float y = sin(u) + v * cos(u/2) * sin(u);
		float z = v * sin(u/2);
		return float3(x, y, z);
	}	
};
cMoebius Moebius;

class cMonkeySaddle : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = u;
		float y = v;
		float z = pow(u,3) - 3 * u * pow(v,2);
    	return float3(x, y, z);
	}	
};
cMonkeySaddle MonkeySaddle;

class cParaboloid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * pow((u/p.y),0.5) * cos(v);
		float y = p.x * pow((u/p.y),0.5) * sin(v);
		float z = (u);
		return float3(x, y, z);
	}	
};
cParaboloid Paraboloid;

class cPillow : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u);
		float y = cos(v);
		float z = sin(u) * sin(v);
		return float3(x, y, z);
	}	
};
cPillow Pillow;

class cPisotTriaxial : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = 0.655866 * cos(1.03002 + u) * (2 + cos(v));
		float y = 0.754878 * cos(1.40772 - u) * (2 + 0.868837 * cos(2.43773 + v));
		float z = 0.868837 * cos(2.43773 + u) * (2 + 0.495098 * cos(0.377696 - v));
		return float3(x, y, z);
	}	
};
cPisotTriaxial PisotTriaxial;

class cRoman2Boy : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = 0.655866 * cos(1.03002 + u) * (2 + cos(v));
		float y = 0.754878 * cos(1.40772 - u) * (2 + 0.868837 * cos(2.43773 + v));
		float z = 0.868837 * cos(2.43773 + u) * (2 + 0.495098 * cos(0.377696 - v));
		return float3(x, y, z);
	}	
};
cRoman2Boy Roman2Boy;

class cShell : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (1 - (u / (TWOPI))) * cos(p.w*u) * (1 + cos(v)) + p.z * cos(p.w*u);
		float y = p.x * (1 - (u / (TWOPI))) * sin(p.w*u) * (1 + cos(v)) + p.z * sin(p.w*u);
		float z = p.y * (u / (TWOPI)) + p.x * (1 - (u / (TWOPI))) * sin(v);
		return float3(x, y, z);
	}	
};
cShell Shell;

class cSine : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * sin(u);
		float y = p.x * sin(v);
		float z = p.x * sin(u+v);
		return float3(x, y, z);
	}	
};
cSine Sine;

class cSlippers : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (2 + cos(u)) * pow(cos(v),3) * sin(v);
		float y = (2 + cos(u+TWOPI/3)) * pow(cos(TWOPI/3+v),2) * pow(sin(TWOPI/3+v),2);
		float z = -(2 + cos(u-TWOPI/3)) * pow(cos(TWOPI/3-v),2) * pow(sin(TWOPI/3-v),3);
		return float3(x, y, z);
	}	
};
cSlippers Slippers;

class cSnail : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = u * cos(v) * sin(u);
		float y = u * cos(u) * cos(v);
		float z = -u * sin(v);
		return float3(x, y, z);
	}	
};
cSnail Snail;

class cSprings : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (1-p.x * cos(v)) * cos(u);
		float y = (1-p.x * cos(v)) * sin(u);
		float z = p.y * (sin(v) + p.z * u /PI);
		return float3(x, y, z);
	}	
};
cSprings Springs;

class cSteinbachScrew : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (u) * cos(v);
       float y = p.x * (u) * sin(v);
       float z = p.x * (v) * cos(u);
      return float3(x, y, z);
	}	
};
cSteinbachScrew SteinbachScrew;

class cStiletto : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
	float x = (2 + cos(u)) * pow(cos(v),3) * sin(v);
	float y = (2 + cos(u + TWOPI/3)) * pow(cos(v + TWOPI/3),2) * pow(sin(v + TWOPI/3),2);
	float z = -(2 + cos(u - TWOPI/3)) * pow(cos(v + TWOPI/3),2) * pow(sin(v + TWOPI/3),2);
	return float3(x, y, z);
	}	
};
cStiletto Stiletto;

class cTear : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = p.x * (1- cos(u)) * sin(u) * cos(v);
		float y = p.x * (1- cos(u)) * sin(u) * sin(v);
		float z = cos(u);
		return float3(x, y, z);
	}	
};
cTear Tear;

class cTractrix : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(u) * (v - tanh(v));
		float y = cos(u) / cosh(v) ;
		float z = pow(x,2) - pow(y,2) + 2*x*y*pow(tanh(u),2);
		return float3(x, y, z);
	}	
};
cTractrix Tractrix;

class cTranguloid : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
  	 	float x = sin(3*u) * 2 / (2 + cos(v));
  		float y = (sin(u) + 2 * sin(2*u)) * 2 / (2 + cos(v + TWOPI / p.x));
  		float z = (cos(u) - 2 * cos(2*u)) * (2 + cos(v)) * ((2 + cos(v + TWOPI/3))*0.25);
   		return float3(x, y, z);
	}	
};
cTranguloid Tranguloid;

class cTriaxialHexatorus : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = sin(u) / (sqrt(2) + cos(v));
		float y = sin(u + TWOPI/3) / (sqrt(2) + cos(v + TWOPI/3));
		float z = cos(u - TWOPI/3) / (sqrt(2) + cos(v - TWOPI/3));
		return float3(x, y, z);
	}	
};
cTriaxialHexatorus TriaxialHexatorus;

class cTriaxialTeardrop : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = (1 - cos(u)) * cos(u + TWOPI / 3) * cos(v + TWOPI / 3) / 2;
		float y = (1 - cosh(u)) * cos(u + TWOPI /3) * cos(v - TWOPI / 3) / 2;
		float z = cos(u - TWOPI / 3) ;
		return float3(x, y, z);
	}	
};
cTriaxialTeardrop TriaxialTeardrop;

class cTriaxialTritorus : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = sin(u) * (1 + cos(v));
		float y = sin(u + TWOPI / 3) * (1 + cos(v + TWOPI / 3));
		float z = sin(u + 2*TWOPI / 3) * (1 + cos(v + 2*TWOPI / 3));
		return float3(x, y, z);
	}	
};
cTriaxialTritorus TriaxialTritorus;

class cTwistedPipe : iSurface
{
	float3 Get(float u, float v, float4 p)
	{
		float x = cos(v) * (2 + cos(u)) / sqrt(1 + pow(sin(v),2));
		float y = sin(v + TWOPI/3) * (2 + cos(u + TWOPI/3)) / sqrt(1 + pow(sin(v),2));
		float z = sin(v - TWOPI/3) * (2 + cos(u - TWOPI/3)) / sqrt(1 + pow(sin(v),2));
     	return float3(x, y, z);
	}	
};
cTwistedPipe TwistedPipe;


// toadd:  
iSurface SurfaceType<string linkclass="Apple,AstroidalEllipsoid,BentHorns,BohemianDome,Bour,Bow,Catalan,Catenoid,Cone,Corkscrew,Cresent,CrossCap,Dini,DoubleCone,Eight,EllipticTorus,Ennepers,Figure8Torus,Fish,Folium,Handkerchief,Helicoid,Henneburg,Horn,Hyperboloid,HyperHelicoid,Jet,Kidney,KleinBottle,KleinCycloid,Kuen,Lemniscape,LimpetTorus,MaedersOwl,Moebius,MonkeySaddle,Paraboloid,Pillow,PisotTriaxial,Roman2Boy,Shell,Sine,Slippers,Snail,Springs,SteinbachScrew,Stiletto,Tear,Tractrix,Tranguloid,TriaxialHexatorus,TriaxialTeardrop,TriaxialTritorus,TwistedPipe";>;

//////////////////////////////////////////////////
/* geomtry indexing interface
	Simple switcher for chossing from Instance, Primitive or Vertex 
	
//place in shader:

iGeomIndex myValueIndexing <string linkclass="Instance,Primitive,Vertex"; string uiname="My Value Indexing";>;

i = myValueIndexing.Get(iid, pid, vid);


*/
interface iGeomIndex
{
   float Get(float iid, float pid, float vid);
};


class cVid : iGeomIndex
{
   float Get(float iid, float pid, float vid)
	{
		return vid;
	}
}; 

class cPid : iGeomIndex
{
   float Get(float iid, float pid, float vid)
	{
		return pid;
	}
}; 

class cIid : iGeomIndex
{
   float Get(float iid, float pid, float vid)
	{
		return iid;
	}
}; 

cVid Vertex;
cPid Primitive;
cIid Instance;



///////////////////////////////////////////////////

//Dispatch///////////////////////////////////////////////////////////////////////////////
float threadCount;

// Place at start of compute function:
/*
	if (dtid.x >= threadCount) { return; }
*/
///////////////////////////////////////////////////////////////////////////////////////

//Buffersize///////////////////////////////////////////////////////////////////////////

float bSize (StructuredBuffer<float> buffer)
{
	uint count, dummy;	
	buffer.GetDimensions(count,dummy);
	return count;
}

float bSize (StructuredBuffer<float2> buffer)
{
	uint count, dummy;	
	buffer.GetDimensions(count,dummy);
	return count;
}

float bSize (StructuredBuffer<float3> buffer)
{
	uint count, dummy;	
	buffer.GetDimensions(count,dummy);
	return count;
}

float bSize (StructuredBuffer<float4> buffer)
{
	uint count, dummy;	
	buffer.GetDimensions(count,dummy);
	return count;
}

float bSize (StructuredBuffer<float4x4> buffer)
{
	uint count, dummy;	
	buffer.GetDimensions(count,dummy);
	return count;
}


///////////////////////////////////////////////////////////////////////////////////////

//Safe Buffer Load with Defualt////////////////////////////////////////////////////////

float bLoad(StructuredBuffer<float> valueBuffer, float defaultValue, float dtid)
{
	float value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

float2 bLoad(StructuredBuffer<float2> valueBuffer, float2 defaultValue, float dtid)
{
	float2 value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

float3 bLoad(StructuredBuffer<float3> valueBuffer, float3 defaultValue, float dtid)
{
	float3 value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

float4 bLoad(StructuredBuffer<float4> valueBuffer, float4 defaultValue, float dtid)
{
	float4 value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}

float4x4 bLoad(StructuredBuffer<float4x4> valueBuffer, float4x4 defaultValue, float dtid)
{
	float4x4 value = defaultValue;
	uint count = bSize(valueBuffer);
	if (count > 0) value = valueBuffer[dtid.x % count];
	return value;
}


///////////////////////////////////////////////////////////////////////////////////////

// //switcable dispatch interface
/*
	float threadCount = DispatchMethod.GetCount();
	if (dtid.x >= threadCount) { return; }

float threadCountDirect; 
ByteAddressBuffer threadCountIndirect;

interface iDispatchMethod
{
   float GetCount();
};

class cDirect : iDispatchMethod
{
  float GetCount()
	{
		return threadCountDirect;
	}
}; 

class cIndirect : iDispatchMethod
{
  float GetCount()
	{
		return threadCountIndirect.Load(0);
	}
};
cDirect Direct;
cIndirect Indirect;
iDispatchMethod DispatchMethod <string linkclass="Direct,Indirect";>;
*/
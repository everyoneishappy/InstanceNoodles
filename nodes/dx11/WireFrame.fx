
float4x4 tWV: WORLDVIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;

float LineWidth = 3;
float4 WireColor  <bool color=true;String uiname="WireColor";>  = {0, 0, 1, 1};


DepthStencilState DSSDepthLessEqual
{
  DepthEnable = true;
  DepthWriteMask = 0x00;
  DepthFunc = Less_Equal;
};

RasterizerState RSFill
{
    FillMode = SOLID;
    CullMode = None;
    DepthBias = false;
    MultisampleEnable = true;
};


BlendState BSBlending
{
    BlendEnable[0] = TRUE;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA ;
    BlendOp = ADD;
    SrcBlendAlpha = SRC_ALPHA;
    DestBlendAlpha = DEST_ALPHA;
    BlendOpAlpha = ADD;
    RenderTargetWriteMask[0] = 0x0F;
};





struct VS_INPUT
{
    float3 Pos  : POSITION;
    float3 Nor  : NORMAL;
   // float3 Tex  : TEXCOORD0;
};

struct GS_INPUT
{
    float4 Pos  : POSITION;
    float4 PosV : TEXCOORD0;
};


struct PS_INPUT_WIRE
{
    float4 Pos : SV_POSITION;
  //  float4 Col : TEXCOORD0;
    float3 Heights : TEXCOORD1;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
GS_INPUT VS( VS_INPUT input )
{
    GS_INPUT output;
    output.Pos = mul(float4(input.Pos, 1), tWVP);
    output.PosV = mul(float4(input.Pos, 1), tWV);
    return output;
}

//--------------------------------------------------------------------------------------
// Geometry Shader
//--------------------------------------------------------------------------------------



[maxvertexcount(3)]
void GS( triangle GS_INPUT input[3],
                         inout TriangleStream<PS_INPUT_WIRE> outStream )
{
    PS_INPUT_WIRE output;

    // Shade and colour face.
   // output.Col = WireColor;

    // Emit the 3 vertices
    // The Height attribute is based on the constant
    output.Pos = input[0].Pos;
    output.Heights = float3( 1, 0, 0 );
    outStream.Append( output );

    output.Pos = input[1].Pos;
    output.Heights = float3( 0, 1, 0 );
    outStream.Append( output );

    output.Pos = input[2].Pos;
    output.Heights = float3( 0, 0, 1 );
	outStream.Append( output );

    outStream.RestartStrip();
}

//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------

float evalMinDistanceToEdges(in PS_INPUT_WIRE input)
{
    float dist;

	float3 ddxHeights = ddx( input.Heights );
	float3 ddyHeights = ddy( input.Heights );
	float3 ddHeights2 =  ddxHeights*ddxHeights + ddyHeights*ddyHeights;
	
    float3 pixHeights2 = input.Heights *  input.Heights / ddHeights2 ;
    
    dist = sqrt( min ( min (pixHeights2.x, pixHeights2.y), pixHeights2.z) );
    
    return dist;
}

float4 PS( PS_INPUT_WIRE input) : SV_Target
{
    // Compute the shortest distance between the fragment and the edges.
    float dist = evalMinDistanceToEdges(input);

    // Cull fragments too far from the edge.
    if (dist > 0.5*LineWidth+1) discard;

    // Map the computed distance to the [0,2] range on the border of the line.
    dist = clamp((dist - (0.5*LineWidth - 1)), 0, 2);

    // Alpha is computed from the function exp2(-2(x)^2).
    dist *= dist;
    float alpha = exp2(-2*dist);

    // Standard wire color
    float4 color = WireColor;
    color.a *= alpha;
	
    return color;
}





//--------------------------------------------------------------------------------------



technique10 Wireframe
{     
    pass
    {
        SetDepthStencilState( DSSDepthLessEqual, 0 );
        SetRasterizerState( RSFill );
        SetBlendState( BSBlending, float4( 0.0f, 0.0f, 0.0f, 0.0f ), 0xFFFFFFFF );
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( CompileShader( gs_4_0, GS() ) );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}







//===========================================================//
// Textures                                                  //
//===========================================================//
Texture2D   TextureOriginal;     //color R10B10G10A2 32 bit ldr format
Texture2D   TextureColor;        //color which is output of previous technique (except when drawed to temporary render target), R10B10G10A2 32 bit ldr format
Texture2D   TextureDepth;        //scene depth R32F 32 bit hdr format

Texture2D   RenderTargetRGBA32;  //R8G8B8A8 32 bit ldr format
Texture2D   RenderTargetRGBA64;  //R16B16G16A16 64 bit ldr format
Texture2D   RenderTargetRGBA64F; //R16B16G16A16F 64 bit hdr format
Texture2D   RenderTargetR16F;    //R16F 16 bit hdr format with red channel only
Texture2D   RenderTargetR32F;    //R32F 32 bit hdr format with red channel only
Texture2D   RenderTargetRGB32F;  //32 bit hdr format without alpha

Texture2D   lut                 <string ResourceName="Include/Textures/neutral1k.png"; >;

//===========================================================//
// Internals                                                 //
//===========================================================//
#include "Include/Shared/Globals.fxh"
#include "Include/Shared/ReforgedUI.fxh"
#include "Include/Shared/Conversions.fxh"
#include "Include/Shared/BlendingModes.fxh"

//===========================================================//
// UI                                                        //
//===========================================================//

UI_MESSAGE(2,                     	"|----- Camera Effects -----")
UI_WHITESPACE(2)
UI_BOOL(enableVingette,             "| Enable Vingette",          	false)
UI_FLOAT(vingetteIntesity,          "|  Vingette Intesity",        	0.0, 1.0, 0.1)
UI_WHITESPACE(3)
UI_BOOL(enableGrain,                "| Enable Grain",             	false)
UI_INT(grainAmount,                 "|  Grain Amount",            	0, 100, 50)
UI_INT(grainRoughness,              "|  Grain Roughness",          	1, 3, 1)
UI_WHITESPACE(5)
UI_BOOL(enableLetterbox,            "| Enable Letterbox",	    	false)
UI_FLOAT(hBoxSize,                  "|  Horizontal Size",			-0.5, 0.5, 0.1)
UI_FLOAT(vBoxSize,                  "|  Vertical Size",          	-0.5, 0.5, 0.0)
UI_FLOAT3(BoxColor,                 "|  Letterbox Color",         	0.0, 0.0, 0.0)
UI_WHITESPACE(6)
UI_BOOL(enableCAS,                  "| Enable CAS Sharpening",      false)
UI_FLOAT(casContrast,               "|  Sharpening Contrast",      	0.0, 1.0, 0.0)
UI_FLOAT(casSharpening,             "|  Sharpening Amount",     	0.0, 1.0, 1.0)
UI_WHITESPACE(7)
UI_BOOL(enableLut,                  "| Enable Lut",                 false)

int	selectLut
<
    string UIName="|  Select Lut";
    string UIWidget="dropdown";
    string UIList="Lut1, Lut2, Lut3, Lut4";
    int UIMin=0;
    int UIMax=3;
>;

//===========================================================//
// Functions                                                 //
//===========================================================//
#include "Include/Shaders/letterbox.fxh"
#include "Include/Shaders/filmGrain.fxh"
#include "Include/Shaders/cas.fxh"
#include "Include/Shaders/lut.fxh"


//===========================================================//
// Pixel Shaders                                             //
//===========================================================//
float4 PS_PostFX(VS_OUTPUT IN, float4 v0 : SV_Position0) : SV_Target
{
    float2 coord    = IN.txcoord.xy;
    float4 Color	= TextureColor.Sample(PointSampler, coord);

    // Lut
    if(enableLut)
    Color.rgb = Lut(Color, lut);

    // Grain
    if(enableGrain)
    Color.rgb = GrainPass(coord, Color);

    // Vingette
    if(enableVingette)
    Color   *= pow(16.0 * coord.x * coord.y * (1.0 - coord.x) * (1.0 - coord.y), vingetteIntesity); // fast and simpel

    //Letterboxes
    if(enableLetterbox)
    Color.rgb = applyLetterbox(Color, coord);

    return Color;
}

float3 PS_CAS(VS_OUTPUT IN) : SV_Target
{
	return enableCAS ? CASsharpening(IN.txcoord.xy) : TextureColor.Sample(PointSampler, IN.txcoord.xy);
}

//===========================================================//
// Techniques                                                //
//===========================================================//

technique11 post <string UIName="Postpass";>
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
        SetPixelShader (CompileShader(ps_5_0, PS_CAS()));
    }
}

technique11 post1
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
        SetPixelShader (CompileShader(ps_5_0, PS_PostFX()));
    }
}
//========================================================//
//                                                        //
//      _/_/_/_/  _/                                      //
//     _/        _/_/_/      _/_/    _/_/_/    _/    _/   //
//    _/_/_/    _/    _/  _/    _/  _/    _/  _/    _/    //
//   _/        _/    _/  _/    _/  _/    _/  _/    _/     //
//  _/_/_/_/  _/_/_/      _/_/    _/    _/    _/_/_/      //
//                                               _/       //
//                                          _/_/          //
//========================================================//
//     An ENB Preset by MechanicalPanda and Adyss         //
//========================================================// 

//========================================================//
// Textures                                               //
//========================================================//
Texture2D   TextureOriginal;     //color R10B10G10A2 32 bit ldr format
Texture2D   TextureColor;        //color which is output of previous technique (except when drawed to temporary render target), R10B10G10A2 32 bit ldr format
Texture2D   TextureDepth;        //scene depth R32F 32 bit hdr format

Texture2D   RenderTargetRGBA32;  //R8G8B8A8 32 bit ldr format
Texture2D   RenderTargetRGBA64;  //R16B16G16A16 64 bit ldr format
Texture2D   RenderTargetRGBA64F; //R16B16G16A16F 64 bit hdr format
Texture2D   RenderTargetR16F;    //R16F 16 bit hdr format with red channel only
Texture2D   RenderTargetR32F;    //R32F 32 bit hdr format with red channel only
Texture2D   RenderTargetRGB32F;  //32 bit hdr format without alpha

// This tex will be replaced by the ENB plugin
Texture2D   lut     <string ResourceName="Include/Textures/neutral1k.png"; >;

//========================================================//
// Internals                                              //
//========================================================//
#include "Include/Shared/Globals.fxh"
#include "Include/Shared/ReforgedUI.fxh"
#include "Include/Shared/Conversions.fxh"
#include "Include/Shared/BlendingModes.fxh"

//========================================================//
// UI                                                     //
//========================================================//

UI_MESSAGE(2,                     	"|----- Camera Effects -----")
UI_WHITESPACE(1)
UI_BOOL(enableGrain,                "| Enable Grain",             	false)
UI_INT(grainAmount,                 "|  Grain Amount",            	0, 100, 50)
UI_INT(grainRoughness,              "|  Grain Roughness",          	1, 3, 1)
UI_WHITESPACE(2)
UI_BOOL(enableLetterbox,            "| Enable Letterbox",	    	false)
UI_FLOAT(hBoxSize,                  "|  Horizontal Size",			-0.5, 0.5, 0.1)
UI_FLOAT(vBoxSize,                  "|  Vertical Size",          	-0.5, 0.5, 0.0)
UI_FLOAT(boxRotation,               "|  Letterbox Rotation",	    0.0, 6.0, 0.0)
UI_WHITESPACE(3)
UI_BOOL(enableVingette,             "| Enable Vingette",          	false)
UI_FLOAT(vingetteIntesity,          "|  Vingette Intesity",        	0.0, 1.0, 0.1)
UI_WHITESPACE(4)
UI_BOOL(enableCAS,                  "| Enable CAS Sharpening",      false)
UI_FLOAT(casContrast,               "|  Sharpening Contrast",      	0.0, 1.0, 0.0)
UI_FLOAT(casSharpening,             "|  Sharpening Amount",     	0.0, 1.0, 1.0)
UI_WHITESPACE(5)
UI_BOOL(enableCA,                   "| Enable Radial CA",           false)
UI_FLOAT(RadialCA,                  "|  Aberration Strength",      	0.0, 2.5, 1.0)
UI_FLOAT(barrelPower,               "|  Aberration Curve",         	0.0, 2.5, 1.0)
UI_WHITESPACE(6)
UI_BOOL(enableLut,                  "| Enable Lut",                 false)
UI_DROPDOWN(selectLut,              "|  Select Lut",                0, 7, 0)
UI_FLOAT(lutIntensity,              "|  Lut Intensity",         	0.0, 1.0, 0.5)


//========================================================//
// Functions                                              //
//========================================================//
#include "Include/Shaders/letterbox.fxh"
#include "Include/Shaders/filmGrain.fxh"
#include "Include/Shaders/cas.fxh"
#include "Include/Shaders/lut.fxh"
#include "Include/Shaders/radialCA.fxh"

//========================================================//
// Pixel Shaders                                          //
//========================================================//
float4 PS_PostFX(VS_OUTPUT IN, float4 v0 : SV_Position0) : SV_Target
{
    float2 coord    = IN.txcoord.xy;
    float4 color	= TextureColor.Sample(PointSampler, coord);

    // Lut
    if(enableLut)
    color.rgb = lerp(color, Lut(color, lut), lutIntensity);

    // Grain
    if(enableGrain)
    color.rgb = GrainPass(coord, color);

    // Letterbox and vingette
    color.rgb = applyLetterbox(color, coord);

    return color;
}

float3 PS_LensCABlur(VS_OUTPUT IN) : SV_Target
{
    return enableCA ? SampleBlurredImage(TextureColor.Sample(LinearSampler, IN.txcoord.xy), IN.txcoord.xy) : TextureColor.Sample(PointSampler, IN.txcoord.xy);
}

float3 PS_LensCA(VS_OUTPUT IN) : SV_Target
{
    return enableCA ? LensCA(IN.txcoord.xy) : TextureColor.Sample(PointSampler, IN.txcoord.xy);
}

float3 PS_CAS(VS_OUTPUT IN) : SV_Target
{
	return enableCAS ? CASsharpening(IN.txcoord.xy) : TextureColor.Sample(PointSampler, IN.txcoord.xy);
}

//========================================================//
// Techniques                                             //
//========================================================//

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
        SetPixelShader (CompileShader(ps_5_0, PS_LensCABlur()));
    }
}

technique11 post2
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
        SetPixelShader (CompileShader(ps_5_0, PS_LensCA()));
    }
}

technique11 post3
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
        SetPixelShader (CompileShader(ps_5_0, PS_PostFX()));
    }
}
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

//==================================================//
// Textures                                 		//
//==================================================//
Texture2D			TextureDepth;
Texture2D			TextureCurrent;  //TextureCurrent size is 256*256, it's internally downscaled from full screen
Texture2D			TexturePrevious; //TexturePrevious size is 1*1

//==================================================//
// Internals                                		//
//==================================================//
float4	 AdaptationParameters; //x = AdaptationMin, y = AdaptationMax, z = AdaptationSensitivity, w = AdaptationTime multiplied by time elapsed
#include "Include/Shared/Globals.fxh"
#include "Include/Shared/ReforgedUI.fxh"

//==================================================//
// UI                                       		//
//==================================================//

UI_INT(AdaptPrecision,            " Adaptation Precision",         2.0, 100.0, 8.0)
UI_FLOAT(AdaptSpeed,              " Adaptation Speed",             0.0, 10.0,  1.0)
UI_FLOAT(MinAdapt,                " Min Adaptation",               0.0, 10.0,  0.0)
UI_FLOAT(MaxAdapt,                " Max Adaptation",               0.0, 10.0,  1.0)

//==================================================//
// Pixel Shaders                            		//
//==================================================//
float	PS_Downsample(VS_OUTPUT IN) : SV_Target
{
	float totalBrightness = 0.0;

	for (int x = 0; x < AdaptPrecision; x++)
	{
		for (int y = 0; y < AdaptPrecision; y++)
		{
			totalBrightness += TextureCurrent.Sample(PointSampler, (float2(x, y) + 0.5) / AdaptPrecision);
		}
	}

	return totalBrightness / (AdaptPrecision * AdaptPrecision);
}

float	PS_Adaptation(VS_OUTPUT IN) : SV_Target
{
	float totalBrightness = 0.0;

	for (int x = 0; x < AdaptPrecision; x++)
	{
		for (int y = 0; y < AdaptPrecision; y++)
		{
			totalBrightness += TextureCurrent.Sample(PointSampler, (float2(x, y) + 0.5) / AdaptPrecision);
		}
	}

	float  currFrame = totalBrightness / (AdaptPrecision * AdaptPrecision);
	float  prevFrame = TexturePrevious.Sample(PointSampler, IN.txcoord.xy).x;
	float  final     = lerp(prevFrame, currFrame, AdaptationParameters.w * AdaptSpeed);
		   final     = max(min(final, 16384.0), 0.001);
		   final     = clamp(final, MinAdapt, MaxAdapt);
	return final;
}

//==================================================//
// Techniques                               		//
//==================================================//
technique11 Downsample
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
		SetPixelShader (CompileShader(ps_5_0, PS_Downsample()));
	}
}

technique11 Draw  <string UIName="Simple Adaptation";>
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
		SetPixelShader (CompileShader(ps_5_0, PS_Adaptation()));
	}
}

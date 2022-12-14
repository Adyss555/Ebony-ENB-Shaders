////////////////////////////////////////////////////////////////////////////////
// Photoshop Blending & Functions                                             //
//                                                                            //
// File written by TreyM                                                      //
// <> from various internet sources                                           //
////////////////////////////////////////////////////////////////////////////////

// OVERLAY FLOAT /////////////////////////////////
float BlendOverlay(float base, float blend)
{
    return lerp((2.0 * base * blend),
                (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)),
                step(blend, 0.5));
}
// OVERLAY FLOAT3 ////////////////////////////////
float3 BlendOverlay(float3 base, float3 blend)
{
    return lerp((2.0 * base * blend),
                (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)),
                step(blend, 0.5));
}
// OVERLAY FLOAT4 ////////////////////////////////
float4 BlendOverlay(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp((2.0 * base * blend),
                 (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)),
                  step(blend, 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// SOFT LIGHT FLOAT //////////////////////////////
float BlendSoftLight(float base, float blend)
{
    return lerp((2.0 * base * blend + base * base * (1.0 - 2.0 * blend)),
                (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)),
                 step(blend, 0.5));
}
// SOFT LIGHT FLOAT3 /////////////////////////////
float3 BlendSoftLight(float3 base, float3 blend)
{
    return lerp((2.0 * base * blend + base * base * (1.0 - 2.0 * blend)),
                (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)),
                 step(blend, 0.5));
}
// SOFT LIGHT FLOAT4 /////////////////////////////
float4 BlendSoftLight(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp((2.0 * base * blend + base * base * (1.0 - 2.0 * blend)),
                 (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)),
                  step(blend, 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// HARD LIGHT FLOAT //////////////////////////////
float BlendHardLight(float base, float blend)
{
    return BlendOverlay(blend, base);
}
// HARD LIGHT FLOAT3 /////////////////////////////
float3 BlendHardLight(float3 base, float3 blend)
{
    return BlendOverlay(blend, base);
}
// HARD LIGHT FLOAT4 /////////////////////////////
float4 BlendHardLight(float4 base, float4 blend, bool alpha = true)
{
    blend = BlendOverlay(blend, base);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// ADD FLOAT /////////////////////////////////////
float BlendAdd(float base, float blend)
{
    return min(base + blend, 1.0);
}
// ADD FLOAT3 ////////////////////////////////////
float3 BlendAdd(float3 base, float3 blend)
{
    return min(base + blend, 1.0);
}
// ADD FLOAT4 ////////////////////////////////////
float4 BlendAdd(float4 base, float4 blend, bool alpha = true)
{
    blend = min(base + blend, 1.0);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// SUBTRACT FLOAT ////////////////////////////////
float BlendSubtract(float base, float blend)
{
    return max(base + blend - 1.0, 0.0);
}
// SUBTRACT FLOAT3 ///////////////////////////////
float3 BlendSubtract(float3 base, float3 blend)
{
    return max(base + blend - 1.0, 0.0);
}
// SUBTRACT FLOAT4 ///////////////////////////////
float4 BlendSubtract(float4 base, float4 blend, bool alpha = true)
{
    blend = max(base + blend - 1.0, 0.0);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// LINEAR DODGE FLOAT ////////////////////////////
float BlendLinearDodge(float base, float blend)
{
    return BlendAdd(base, blend);
}
// LINEAR DODGE FLOAT3 ///////////////////////////
float3 BlendLinearDodge(float3 base, float3 blend)
{
    return BlendAdd(base, blend);
}
// LINEAR DODGE FLOAT4 ///////////////////////////
float4 BlendLinearDodge(float4 base, float4 blend, bool alpha = true)
{
    blend = BlendAdd(base, blend);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// LINEAR BURN FLOAT /////////////////////////////
float BlendLinearBurn(float base, float blend)
{
    return BlendSubtract(base, blend);
}
// LINEAR BURN FLOAT3 ////////////////////////////
float3 BlendLinearBurn(float3 base, float3 blend)
{
    return BlendSubtract(base, blend);
}
// LINEAR BURN FLOAT4 ////////////////////////////
float4 BlendLinearBurn(float4 base, float4 blend, bool alpha = true)
{
    blend = BlendSubtract(base, blend);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// LIGHTEN FLOAT /////////////////////////////////
float BlendLighten(float base, float blend)
{
    return max(blend, base);
}
// LIGHTEN FLOAT3 ////////////////////////////////
float3 BlendLighten(float3 base, float3 blend)
{
    return max(blend, base);
}
// LIGHTEN FLOAT4 ////////////////////////////////
float4 BlendLighten(float4 base, float4 blend, bool alpha = true)
{
    blend = max(blend, base);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// DARKEN FLOAT //////////////////////////////////
float BlendDarken(float base, float blend)
{
    return min(blend, base);
}
// DARKEN FLOAT3 /////////////////////////////////
float3 BlendDarken(float3 base, float3 blend)
{
    return min(blend, base);
}
// DARKEN FLOAT4 /////////////////////////////////
float4 BlendDarken(float4 base, float4 blend, bool alpha = true)
{
    blend = min(blend, base);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// LINEAR LIGHT FLOAT ////////////////////////////
float BlendLinearLight(float base, float blend)
{
    return lerp(BlendLinearBurn(base, (2.0 *  blend)),
                BlendLinearDodge(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// LINEAR LIGHT FLOAT3 ///////////////////////////
float3 BlendLinearLight(float3 base, float3 blend)
{
    return lerp(BlendLinearBurn(base, (2.0 *  blend)),
                BlendLinearDodge(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// LINEAR LIGHT FLOAT4 ///////////////////////////
float4 BlendLinearLight(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(BlendLinearBurn(base, (2.0 *  blend)),
                 BlendLinearDodge(base, (2.0 * (blend - 0.5))),
                 step(blend, 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// SCREEN FLOAT //////////////////////////////////
float BlendScreen(float base, float blend)
{
    return 1.0 - ((1.0 - base) * (1.0 - blend));
}
// SCREEN FLOAT3 /////////////////////////////////
float3 BlendScreen(float3 base, float3 blend)
{
    return 1.0 - ((1.0 - base) * (1.0 - blend));
}
// SCREEN FLOAT4 /////////////////////////////////
float4 BlendScreen(float4 base, float4 blend, bool alpha = true)
{
    blend = 1.0 - ((1.0 - base) * (1.0 - blend));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// SCREEN FLOAT HDR //////////////////////////////
float BlendScreenHDR(float base, float blend)
{
    return base + (blend / (1 + base));
}
// SCREEN FLOAT3 HDR /////////////////////////////
float3 BlendScreenHDR(float3 base, float3 blend)
{
    return base + (blend / (1 + base));
}
// SCREEN FLOAT4 HDR /////////////////////////////
float4 BlendScreenHDR(float4 base, float4 blend, bool alpha = true)
{
    blend = base + (blend / (1 + base));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// COLOR DODGE FLOAT /////////////////////////////
float BlendColorDodge(float base, float blend)
{
    return lerp(blend, min(base / (1.0 - blend), 1.0), (blend == 1.0));
}
// COLOR DODGE FLOAT3 ////////////////////////////
float3 BlendColorDodge(float3 base, float3 blend)
{
    return lerp(blend, min(base / (1.0 - blend), 1.0), (blend == 1.0));
}
// COLOR DODGE FLOAT4 ////////////////////////////
float4 BlendColorDodge(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(blend, min(base / (1.0 - blend), 1.0), (blend == 1.0));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// COLOR BURN FLOAT //////////////////////////////
float BlendColorBurn(float base, float blend)
{
    return lerp(blend, max((1.0 - ((1.0 - base) / blend)), 0.0), (blend == 0.0));
}
// COLOR BURN FLOAT3 /////////////////////////////
float3 BlendColorBurn(float3 base, float3 blend)
{
    return lerp(blend, max((1.0 - ((1.0 - base) / blend)), 0.0), (blend == 0.0));
}
// COLOR BURN FLOAT4 /////////////////////////////
float4 BlendColorBurn(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(blend, max((1.0 - ((1.0 - base) / blend)), 0.0), (blend == 0.0));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// VIVID LIGHT FLOAT /////////////////////////////
float BlendVividLight(float base, float blend)
{
    return lerp(BlendColorBurn (base, (2.0 *  blend)),
                BlendColorDodge(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// VIVID LIGHT FLOAT3 ////////////////////////////
float3 BlendVividLight(float3 base, float3 blend)
{
    return lerp(BlendColorBurn (base, (2.0 *  blend)),
                BlendColorDodge(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// VIVID LIGHT FLOAT4 ////////////////////////////
float4 BlendVividLight(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(BlendColorBurn (base, (2.0 *  blend)),
                 BlendColorDodge(base, (2.0 * (blend - 0.5))),
                 step(blend, 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// PIN LIGHT FLOAT ///////////////////////////////
float BlendPinLight(float base, float blend)
{
    return lerp(BlendDarken (base, (2.0 *  blend)),
                BlendLighten(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// PIN LIGHT FLOAT3 //////////////////////////////
float3 BlendPinLight(float3 base, float3 blend)
{
    return lerp(BlendDarken (base, (2.0 *  blend)),
                BlendLighten(base, (2.0 * (blend - 0.5))),
                step(blend, 0.5));
}
// PIN LIGHT FLOAT4 //////////////////////////////
float4 BlendPinLight(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(BlendDarken (base, (2.0 *  blend)),
                 BlendLighten(base, (2.0 * (blend - 0.5))),
                 step(blend, 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// HARD MIX FLOAT ////////////////////////////////
float BlendHardMix(float base, float blend)
{
    return lerp(0.0, 1.0, step(BlendVividLight(base, blend), 0.5));
}
// HARD MIX FLOAT3 ///////////////////////////////
float3 BlendHardMix(float3 base, float3 blend)
{
    return lerp(0.0, 1.0, step(BlendVividLight(base, blend), 0.5));
}
// HARD MIX FLOAT4 ///////////////////////////////
float4 BlendHardMix(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(0.0, 1.0, step(BlendVividLight(base, blend), 0.5));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// REFLECT FLOAT /////////////////////////////////
float BlendReflect(float base, float blend)
{
    return lerp(blend, min(base * base / (1.0 - blend), 1.0), (blend == 1.0));
}
// REFLECT FLOAT3 ////////////////////////////////
float3 BlendReflect(float3 base, float3 blend)
{
    return lerp(blend, min(base * base / (1.0 - blend), 1.0), (blend == 1.0));
}
// REFLECT FLOAT4 ////////////////////////////////
float4 BlendReflect(float4 base, float4 blend, bool alpha = true)
{
    blend = lerp(blend, min(base * base / (1.0 - blend), 1.0), (blend == 1.0));

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// AVERAGE FLOAT /////////////////////////////////
float BlendAverage(float base, float blend)
{
    return (base + blend) / 2.0;
}
// AVERAGE FLOAT3 ////////////////////////////////
float3 BlendAverage(float3 base, float3 blend)
{
    return (base + blend) / 2.0;
}
// AVERAGE FLOAT4 ////////////////////////////////
float4 BlendAverage(float4 base, float4 blend, bool alpha = true)
{
    blend = (base + blend) / 2.0;

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// DIFFERENCE FLOAT //////////////////////////////
float BlendDifference(float base, float blend)
{
    return abs(base - blend);
}
// DIFFERENCE FLOAT3 /////////////////////////////
float3 BlendDifference(float3 base, float3 blend)
{
    return abs(base - blend);
}
// DIFFERENCE FLOAT4 /////////////////////////////
float4 BlendDifference(float4 base, float4 blend, bool alpha = true)
{
    blend = abs(base - blend);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// NEGATION FLOAT ////////////////////////////////
float BlendNegation(float base, float blend)
{
    return 1.0 - abs(1.0 - base - blend);
}
// NEGATION FLOAT3 ///////////////////////////////
float3 BlendNegation(float3 base, float3 blend)
{
    return 1.0 - abs(1.0 - base - blend);
}
// NEGATION FLOAT4 ///////////////////////////////
float4 BlendNegation(float4 base, float4 blend, bool alpha = true)
{
    blend = 1.0 - abs(1.0 - base - blend);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// EXCLUSION FLOAT ///////////////////////////////
float BlendExclusion(float base, float blend)
{
    return base + blend - 2.0 * base * blend;
}
// EXCLUSION FLOAT3 //////////////////////////////
float3 BlendExclusion(float3 base, float3 blend)
{
    return base + blend - 2.0 * base * blend;
}
// EXCLUSION FLOAT4 //////////////////////////////
float4 BlendExclusion(float4 base, float4 blend, bool alpha = true)
{
    blend = base + blend - 2.0 * base * blend;

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// GLOW FLOAT ////////////////////////////////////
float BlendGlow(float base, float blend)
{
    return BlendReflect(blend, base);
}
// GLOW FLOAT3 ///////////////////////////////////
float3 BlendGlow(float3 base, float3 blend)
{
    return BlendReflect(blend, base);
}
// GLOW FLOAT4 ///////////////////////////////////
float4 BlendGlow(float4 base, float4 blend, bool alpha = true)
{
    blend = BlendReflect(blend, base);

    return float4(blend.rgb, alpha? blend.a : base.a);
}



// PHOENIX FLOAT /////////////////////////////////
float BlendPhoenix(float base, float blend)
{
    return min(base, blend) - max(base, blend) + 1.0;
}
// PHOENIX FLOAT3 ////////////////////////////////
float3 BlendPhoenix(float3 base, float3 blend)
{
    return min(base, blend) - max(base, blend) + 1.0;
}
// PHOENIX FLOAT4 ////////////////////////////////
float4 BlendPhoenix(float4 base, float4 blend, bool alpha = true)
{
    blend = min(base, blend) - max(base, blend) + 1.0;

    return float4(blend.rgb, alpha? blend.a : base.a);
}


// ADVANCED FUNCTIONS //////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////


// HUE FLOAT3 ////////////////////////////////////
float3 BlendHue(float3 base, float3 blend)
{
	float3 baseHSL = RGBtoHSL(base);
	return HSLtoRGB(float3(RGBtoHSL(blend).r, baseHSL.g, baseHSL.b));
}
// HUE FLOAT4 ////////////////////////////////////
float4 BlendHue(float4 base, float4 blend, bool alpha = true)
{
	float3 baseHSL = RGBtoHSL(base.rgb);
	return float4(HSLtoRGB(float3(RGBtoHSL(blend.rgb).r, baseHSL.g, baseHSL.b)), base.a);
}



// SATURATION FLOAT3 /////////////////////////////
float3 BlendSaturation(float3 base, float3 blend)
{
	float3 baseHSL = RGBtoHSL(base);
	return HSLtoRGB(float3(baseHSL.r, RGBtoHSL(blend).g, baseHSL.b));
}
// SATURATION FLOAT4 /////////////////////////////
float4 BlendSaturation(float4 base, float4 blend)
{
	float3 baseHSL = RGBtoHSL(base.rgb);
	return float4(HSLtoRGB(float3(baseHSL.r, RGBtoHSL(blend.rgb).g, baseHSL.b)), base.a);
}



// COLOR FLOAT3 //////////////////////////////////
float3 BlendColor(float3 base, float3 blend)
{
    float3 blendHSL = RGBtoHSL(blend);
    return HSLtoRGB(float3(blendHSL.r, blendHSL.g, RGBtoHSL(base).b));
}
// COLOR FLOAT4 //////////////////////////////////
float4 BlendColor(float4 base, float4 blend, bool alpha = true)
{
    float3 blendHSL = RGBtoHSL(blend.rgb);
    return float4(HSLtoRGB(float3(blendHSL.r, blendHSL.g, RGBtoHSL(base.rgb).b)), base.a);
}



// LUMINOSITY FLOAT3 /////////////////////////////
float3 BlendLuminosity(float3 base, float3 blend)
{
	float3 baseHSL = RGBtoHSL(base);
	return HSLtoRGB(float3(baseHSL.r, baseHSL.g, RGBtoHSL(blend).b));
}
// LUMINOSITY FLOAT4 /////////////////////////////
float4 BlendLuminosity(float4 base, float4 blend, bool alpha = true)
{
	float3 baseHSL = RGBtoHSL(base.rgb);
	return float4(HSLtoRGB(float3(baseHSL.r, baseHSL.g, RGBtoHSL(blend.rgb).b)), base.a);
}



// CONTRAST, SATURATION, & BRIGHTNESS FLOAT3 /////
float3 ConSatBri(float3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;

	const float3 LumCoeff = float3(0.2125, 0.7154, 0.0721);

	float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
	float3 brtColor = color * brt;
	float intensityf = dot(brtColor, LumCoeff);
	float3 intensity = float3(intensityf, intensityf, intensityf);
	float3 satColor = lerp(intensity, brtColor, sat);
	float3 conColor = lerp(AvgLumin, satColor, con);
	return conColor;
}
// CONTRAST, SATURATION, & BRIGHTNESS FLOAT4 /////
float4 ConSatBri(float4 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;

	const float3 LumCoeff = float3(0.2125, 0.7154, 0.0721);

	float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
	float3 brtColor = color.rgb * brt;
	float intensityf = dot(brtColor, LumCoeff);
	float3 intensity = float3(intensityf, intensityf, intensityf);
	float3 satColor = lerp(intensity, brtColor, sat);
	float3 conColor = lerp(AvgLumin, satColor, con);
	return float4(conColor, color.a);
}



// LEVELS INPUT RANGE FLOAT //////////////////////
float PSLevelsInputRange(float color, float inmin, float inmax)
{
    return min(max(color - inmin, 0.0) / (inmax - inmin), 1.0);
}
// LEVELS INPUT RANGE FLOAT3 /////////////////////
float3 PSLevelsInputRange(float3 color, float3 inmin, float3 inmax)
{
    return min(max(color - inmin, 0.0) / (inmax - inmin), 1.0);
}

// LEVELS INPUT CONTROL FLOAT ////////////////////
float PSLevelsInputControl(float color, float inmin, float gamma, float inmax)
{
    return pow(PSLevelsInputRange(color, inmin, inmax), gamma);
}
// LEVELS INPUT CONTROL FLOAT3 ///////////////////
float3 PSLevelsInputControl(float3 color, float3 inmin, float3 gamma, float3 inmax)
{
    return pow(PSLevelsInputRange(color, inmin, inmax), gamma);
}

// LEVELS OUTPUT RANGE FLOAT /////////////////////
float PSLevelsControlOutputRange(float color, float outmin, float outmax)
{
    return lerp(outmin, outmax, color);
}
// LEVELS OUTPUT RANGE FLOAT3 ////////////////////
float3 PSLevelsControlOutputRange(float3 color, float3 outmin, float3 outmax)
{
    return lerp(outmin, outmax, color);
}

// LEVELS CONTROL FLOAT //////////////////////////
float PSLevels(float color, float gamma, float inmin, float inmax, float outmin = 0.0, float outmax = 255.0)
{
    return PSLevelsControlOutputRange(PSLevelsInputControl(color, inmin / 255.0, gamma, inmax / 255.0), outmin / 255.0, outmax / 255.0);
}
// LEVELS CONTROL FLOAT3 /////////////////////////
float3 PSLevels(float3 color, float gamma, float3 inmin, float3 inmax, float3 outmin = 0.0, float3 outmax = 255.0)
{
    return PSLevelsControlOutputRange(PSLevelsInputControl(color, inmin / 255.0, gamma, inmax / 255.0), outmin / 255.0, outmax / 255.0);
}

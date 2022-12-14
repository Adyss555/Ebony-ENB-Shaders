//==================================================//
// Sunglare Shader by Adyss based on Boris original //
//==================================================//

//==================================================//
// Textures                                         //
//==================================================//
Texture2D		TextureMask;        // mask of sun as visibility factor
Texture2D       TextureDepth;       // Ignore
Texture2D       SpriteTexture1 <string ResourceName="Include/Textures/sunsprite1.png"; >;
Texture2D       SpriteTexture2 <string ResourceName="Include/Textures/sunsprite2.png"; >;
Texture2D       SpriteTexture3 <string ResourceName="Include/Textures/sunsprite3.png"; >;

//==================================================//
// Internals                                        //
//==================================================//
float4    LightParameters;
#include "Include/Shared/Globals.fxh"
#include "Include/Shared/ReforgedUI.fxh"

//==================================================//
// UI                                               //
//==================================================//

#define UI_PREFIX_MODE PREFIX
#define UI_CATEGORY Globals
UI_FLOAT(GlobalIntensity,     "Glare Intensity",                  0.0, 5.0, 0.5)
UI_WHITESPACE(2)
#define UI_CATEGORY Glare1
UI_SEPARATOR
UI_INT(sSelectTex1,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity1,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset1,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale1,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation1,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor1,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(3)
#define UI_CATEGORY Glare2
UI_SEPARATOR
UI_INT(sSelectTex2,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity2,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset2,            "Offset",                         -5.0, 10.0, 0.3)
UI_FLOAT(sScale2,             "Scale",                           0.0, 10.0, 0.2)
UI_FLOAT(sRotation2,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor2,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(4)
#define UI_CATEGORY Glare3
UI_SEPARATOR
UI_INT(sSelectTex3,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity3,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset3,            "Offset",                         -5.0, 10.0, 0.4)
UI_FLOAT(sScale3,             "Scale",                           0.0, 10.0, 0.3)
UI_FLOAT(sRotation3,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor3,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(5)
#define UI_CATEGORY Glare4
UI_SEPARATOR
UI_INT(sSelectTex4,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity4,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset4,            "Offset",                         -5.0, 10.0, 0.5)
UI_FLOAT(sScale4,             "Scale",                           0.0, 10.0, 0.4)
UI_FLOAT(sRotation4,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor4,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(6)
#define UI_CATEGORY Glare5
UI_SEPARATOR
UI_INT(sSelectTex5,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity5,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset5,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale5,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation5,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor5,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(7)
#define UI_CATEGORY Glare6
UI_SEPARATOR
UI_INT(sSelectTex6,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity6,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset6,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale6,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation6,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor6,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(8)
#define UI_CATEGORY Glare7
UI_SEPARATOR
UI_INT(sSelectTex7,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity7,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset7,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale7,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation7,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor7,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(9)
#define UI_CATEGORY Glare8
UI_SEPARATOR
UI_INT(sSelectTex8,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity8,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset8,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale8,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation8,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor8,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(10)
#define UI_CATEGORY Glare9
UI_SEPARATOR
UI_INT(sSelectTex9,           "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity9,         "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset9,            "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale9,             "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation9,          "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor9,      "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(11)
#define UI_CATEGORY Glare10
UI_SEPARATOR
UI_INT(sSelectTex10,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity10,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset10,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale10,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation10,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor10,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(12)
#define UI_CATEGORY Glare11
UI_SEPARATOR
UI_INT(sSelectTex11,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity11,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset11,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale11,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation11,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor11,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(13)
#define UI_CATEGORY Glare12
UI_SEPARATOR
UI_INT(sSelectTex12,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity12,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset12,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale12,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation12,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor12,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(14)
#define UI_CATEGORY Glare13
UI_SEPARATOR
UI_INT(sSelectTex13,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity13,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset13,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale13,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation13,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor13,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(15)
#define UI_CATEGORY Glare14
UI_SEPARATOR
UI_INT(sSelectTex14,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity14,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset14,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale14,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation14,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor14,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(16)
#define UI_CATEGORY Glare15
UI_SEPARATOR
UI_INT(sSelectTex15,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity15,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset15,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale15,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation15,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor15,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(17)
#define UI_CATEGORY Glare16
UI_SEPARATOR
UI_INT(sSelectTex16,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity16,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset16,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale16,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation16,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor16,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(18)
#define UI_CATEGORY Glare17
UI_SEPARATOR
UI_INT(sSelectTex17,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity17,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset17,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale17,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation17,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor17,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(19)
#define UI_CATEGORY Glare18
UI_SEPARATOR
UI_INT(sSelectTex18,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity18,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset18,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale18,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation18,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor18,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(20)
#define UI_CATEGORY Glare19
UI_SEPARATOR
UI_INT(sSelectTex19,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity19,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset19,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale19,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation19,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor19,     "Color",                           1.0, 1.0, 1.0)
UI_WHITESPACE(21)
#define UI_CATEGORY Glare20
UI_SEPARATOR
UI_INT(sSelectTex20,          "Selet Texture",                   1.0, 3.0, 1.0)
UI_FLOAT(sIntensity20,        "Intensity",                       0.0, 5.0,  0.5)
UI_FLOAT(sOffset20,           "Offset",                         -5.0, 10.0, 0.2)
UI_FLOAT(sScale20,            "Scale",                           0.0, 10.0, 0.1)
UI_FLOAT(sRotation20,         "Rotation",                        0.0, 6.0, 0.0)
UI_FLOAT3(sSpriteColor20,     "Color",                           1.0, 1.0, 1.0)

//==================================================//
// Functions                                        //
//==================================================//


//==================================================//
// Pixel Shaders                                    //
//==================================================//

VS_OUTPUT VS_Sprite(VS_INPUT IN, uniform float offset, uniform float scale)
{
	VS_OUTPUT OUT;
	float4 pos;
	       pos.xyz     = IN.pos.xyz;
           pos.w       = 1.0;
	       pos.y      *= ScreenSize.z;
	float2 shift       = LightParameters.xy * offset;
	       pos.xy      = pos.xy * scale - shift;
	   OUT.pos         = pos;
	   OUT.txcoord.xy  = IN.txcoord.xy;
	return OUT;
}

float3	PS_DrawSprite(VS_OUTPUT IN, uniform float Intensity, uniform float3 SpriteColor, uniform float Rotation, uniform float SelectTex) : SV_Target
{
    float    s               = sin(Rotation);
    float    c               = cos(Rotation);
    float2x2 RotationMatrix  = float2x2( c, -s, s, c);
             RotationMatrix *= 0.5; // Matrix Correction to fix on center point
	         RotationMatrix += 0.5;
	         RotationMatrix  = RotationMatrix * 2 - 1;
    float2   FinalCoord      = mul (IN.txcoord.xy - 0.5, RotationMatrix);
	         FinalCoord     += 0.5;

    float3   Weight          = SpriteColor * LightParameters.w * Intensity * GlobalIntensity;
    float3   Color;
             if (SelectTex == 1)
             Color           = SpriteTexture1.Sample(LinearSampler, FinalCoord);
             if (SelectTex == 2)
             Color           = SpriteTexture2.Sample(LinearSampler, FinalCoord);
             if (SelectTex == 3)
             Color           = SpriteTexture3.Sample(LinearSampler, FinalCoord);

    return   Color * Weight;
}

//==================================================//
// Techniques                                       //
//==================================================//
technique11 Sprites <string UIName="Sunglare";>
{
    pass p0
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset1, sScale1)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity1, sSpriteColor1, sRotation1, sSelectTex1)));
    }
    pass p1
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset2, sScale2)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity2, sSpriteColor2, sRotation2, sSelectTex2)));
    }
    pass p2
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset3, sScale3)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity3, sSpriteColor3, sRotation3, sSelectTex3)));
    }
    pass p3
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset4, sScale4)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity4, sSpriteColor4, sRotation4, sSelectTex4)));
    }
    pass p4
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset5, sScale5)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity5, sSpriteColor5, sRotation5, sSelectTex5)));
    }
    pass p5
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset6, sScale6)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity6, sSpriteColor6, sRotation6, sSelectTex6)));
    }
    pass p6
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset7, sScale7)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity7, sSpriteColor7, sRotation7, sSelectTex7)));
    }
    pass p7
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset8, sScale8)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity8, sSpriteColor8, sRotation8, sSelectTex8)));
    }
    pass p8
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset9, sScale9)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity9, sSpriteColor9, sRotation9, sSelectTex9)));
    }
    pass p9
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset10, sScale10)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity10, sSpriteColor10, sRotation10, sSelectTex10)));
    }
    pass p10
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset11, sScale11)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity11, sSpriteColor11, sRotation11, sSelectTex11)));
    }
    pass p11
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset12, sScale12)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity12, sSpriteColor12, sRotation12, sSelectTex12)));
    }
    pass p12
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset13, sScale13)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity13, sSpriteColor13, sRotation13, sSelectTex13)));
    }
    pass p13
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset14, sScale14)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity14, sSpriteColor14, sRotation14, sSelectTex14)));
    }
    pass p14
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset15, sScale15)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity15, sSpriteColor15, sRotation15, sSelectTex15)));
    }
    pass p15
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset16, sScale16)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity16, sSpriteColor16, sRotation16, sSelectTex16)));
    }
    pass p16
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset17, sScale17)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity17, sSpriteColor17, sRotation17, sSelectTex17)));
    }
    pass p17
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset18, sScale18)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity18, sSpriteColor18, sRotation18, sSelectTex18)));
    }
    pass p18
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset19, sScale19)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity19, sSpriteColor19, sRotation19, sSelectTex19)));
    }
    pass p19
    {
        SetVertexShader(CompileShader(vs_5_0, VS_Sprite(sOffset20, sScale20)));
        SetPixelShader (CompileShader(ps_5_0, PS_DrawSprite(sIntensity20, sSpriteColor20, sRotation20, sSelectTex20)));
    }
}

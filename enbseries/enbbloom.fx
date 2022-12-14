

//===========================================================//
// Textures                                                  //
//===========================================================//
Texture2D   TextureDepth;
Texture2D   TextureColor;
Texture2D   TextureDownsampled;  //color R16B16G16A16 64 bit or R11G11B10 32 bit hdr format. 1024*1024 size
Texture2D   RenderTarget1024;    //R16B16G16A16F 64 bit hdr format, 1024*1024 size
Texture2D   RenderTarget512;     //R16B16G16A16F 64 bit hdr format, 512*512 size
Texture2D   RenderTarget256;     //R16B16G16A16F 64 bit hdr format, 256*256 size
Texture2D   RenderTarget128;     //R16B16G16A16F 64 bit hdr format, 128*128 size
Texture2D   RenderTarget64;      //R16B16G16A16F 64 bit hdr format, 64*64 size
Texture2D   RenderTarget32;      //R16B16G16A16F 64 bit hdr format, 32*32 size
Texture2D   RenderTarget16;      //R16B16G16A16F 64 bit hdr format, 16*16 size

Texture2D   RenderTargetRGBA32;  // R8G8B8A8 32 bit ldr format
Texture2D   RenderTargetRGBA64;  // R16B16G16A16 64 bit ldr format
Texture2D   RenderTargetRGBA64F; // R16B16G16A16F 64 bit hdr format
Texture2D   RenderTargetR16F;    // R16F 16 bit hdr format with red channel only
Texture2D   RenderTargetR32F;    // R32F 32 bit hdr format with red channel only
Texture2D   RenderTargetRGB32F;  // 32 bit hdr format without alpha

//===========================================================//
// Internals                                                 //
//===========================================================//
#include "Include/Shared/Globals.fxh"
#include "Include/Shared/ReforgedUI.fxh"

//===========================================================//
// UI                                                        //
//===========================================================//

#define MAXBLOOM 16384.0

UI_MESSAGE(1,                   "|----- Main Bloom -----")
UI_FLOAT_DNI(bloomIntensity,    "| Intensity",               0.0, 3.0, 1.0)
UI_FLOAT_DNI(bloomThreshold,    "| Threshhold",              0.0, 1.0, 0.1)
UI_FLOAT_DNI(bloomSensitivity,  "| Sensitivity",             0.1, 3.0, 1.0)
UI_FLOAT_DNI(bloomSaturation,   "| Saturation",              0.1, 2.5, 1.0)
UI_FLOAT(removeSky,             "| Mask out Sky",            0.0, 1.0, 0.2)
UI_WHITESPACE(1)
UI_MESSAGE(2,                   "|----- Soft Bloom -----")
UI_FLOAT_DNI(sHighlightBias,    "| Highlight Bias",         0.0, 1.0, 0.2)
UI_FLOAT_DNI(sBloomIntensity,   "| Soft Bloom Intensity",   0.0, 3.0, 1.0)
UI_FLOAT_DNI(sBloomMixing,      "| Soft Bloom Mixing",      0.0, 1.0, 0.1)

//===========================================================//
// Functions                                                 //
//===========================================================//
float2 getPixelSize(float texsize)
{
    return (1 / texsize) * float2(1, ScreenSize.z);
}

// Box Blur
float4 simpleBlur(Texture2D inputTex, float2 coord, float2 pixelsize)
{
    float4 Blur = 0.0;

    static const float2 Offsets[4]=
    {
        float2(0.5, 0.5),
        float2(0.5, -0.5),
        float2(-0.5, 0.5),
        float2(-0.5, -0.5)
    };

    for (int i = 0; i < 4; i++)
    {
        Blur += inputTex.Sample(LinearSampler, coord + Offsets[i] * pixelsize);
    }

    return Blur * 0.25;
}

//===========================================================//
// Pixel Shaders                                             //
//===========================================================//
float3	PS_Prepass(VS_OUTPUT IN, uniform Texture2D InputTex) : SV_Target
{
    float3  color   = InputTex.Sample(LinearSampler, IN.txcoord.xy) * bloomIntensity;
    float   bright  = max3(color);
    float   mask    = max(0, bright - bloomThreshold);
            mask   /= max(bright, 0.0001);
            color   = pow(color * mask, bloomSensitivity);
            color   = lerp(GetLuma(color, Rec709), color, bloomSaturation);
            color   = lerp(color, color * (1 - floor(getLinearizedDepth(IN.txcoord.xy))), removeSky);
    return  clamp(color, 0.0, MAXBLOOM);
}

float3  PS_BlurH(VS_OUTPUT IN, uniform Texture2D InputTex, uniform float texsize) : SV_Target
{
    int     samples     = 8;
    int     mid         = 2;
    int     upper       = samples * 0.5;
    int     lower       = -upper;
    float2  pixelSize   = getPixelSize(texsize);
    float   kernelSum   = 0.0;
    float3  color;
    
    for (int x = lower; x <= upper; x++)
    {
        float weight = mid - sqrt(abs(x));
        kernelSum   += weight;
        color       += InputTex.Sample(LinearSampler, IN.txcoord.xy + float2(pixelSize.x * x, 0.0)) * weight;
    }
    return color / kernelSum;
}

float3  PS_BlurV(VS_OUTPUT IN, uniform Texture2D InputTex, uniform float texsize) : SV_Target
{
    int     samples     = 8;
    int     mid         = 2;
    int     upper       = samples * 0.5;
    int     lower       = -upper;
    float2  pixelSize   = getPixelSize(texsize);
    float   kernelSum   = 0.0;
    float3  color;

    for (int y = lower; y <= upper; y++)
    {
        float weight = mid - sqrt(abs(y));
        kernelSum   += weight;
        color       += InputTex.Sample(LinearSampler, IN.txcoord.xy + float2(0.0, pixelSize.y * y)) * weight;
    }
    return color / kernelSum;
}

float3  PS_TexCombine(VS_OUTPUT IN) : SV_Target
{
    float2 coord  = IN.txcoord.xy;
    float3 bloom  = 0;
           bloom += simpleBlur(RenderTarget1024, coord, getPixelSize(1024));
           bloom += simpleBlur(RenderTarget512,  coord, getPixelSize(512));
           bloom += simpleBlur(RenderTarget128,  coord, getPixelSize(128));
           bloom += simpleBlur(RenderTarget32,   coord, getPixelSize(32));
    return clamp(bloom * 0.25, 0.0, MAXBLOOM);
}

float3  PS_SoftPrepass(VS_OUTPUT IN) : SV_Target
{
    float2 coord  = IN.txcoord.xy;
    float3 bloom  = RenderTargetRGBA64F.Sample(LinearSampler, coord);
    float3 color  = TextureDownsampled.SampleLevel(LinearSampler, coord, 0);

    return clamp(lerp(color, bloom, sHighlightBias) * sBloomIntensity, 0.0, MAXBLOOM);
}

float3  PS_SoftPostpass(VS_OUTPUT IN) : SV_Target
{
    float2 coord  = IN.txcoord.xy;
    float3 bloom  = RenderTargetRGBA64F.SampleLevel(LinearSampler, coord, 0);
    float3 sBloom = TextureColor.SampleLevel(LinearSampler, coord, 0);

    return clamp(bloom + (sBloom * sBloomMixing), 0.0, MAXBLOOM);
}

// https://www.froyok.fr/blog/2021-12-ue4-custom-bloom/
float3  PS_Downsample(VS_OUTPUT IN, uniform Texture2D InputTex, uniform float texsize) : SV_Target
{
    const float2 coords[13] = {
        float2( -1.0f,  1.0f ), float2(  1.0f,  1.0f ),
        float2( -1.0f, -1.0f ), float2(  1.0f, -1.0f ),

        float2(-2.0f, 2.0f), float2( 0.0f, 2.0f), float2( 2.0f, 2.0f),
        float2(-2.0f, 0.0f), float2( 0.0f, 0.0f), float2( 2.0f, 0.0f),
        float2(-2.0f,-2.0f), float2( 0.0f,-2.0f), float2( 2.0f,-2.0f)
    };

    const float weights[13] = {
        // 4 samples
        // (1 / 4) * 0.5f = 0.125f
        0.125f, 0.125f,
        0.125f, 0.125f,

        // 9 samples
        // (1 / 9) * 0.5f
        0.0555555f, 0.0555555f, 0.0555555f,
        0.0555555f, 0.0555555f, 0.0555555f,
        0.0555555f, 0.0555555f, 0.0555555f
    };

    float3 color = 0.0;

    [unroll]
    for( int i = 0; i < 13; i++ )
    {
        float2 currentUV = IN.txcoord.xy + coords[i] * getPixelSize(texsize);
        color += weights[i] * InputTex.Sample(LinearSampler, currentUV);
    }

    return color; 
}

float3  PS_Upsample(VS_OUTPUT IN, uniform Texture2D InputTex, uniform float texsize) : SV_Target
{
    const float2 coords[9] = {
        float2( -1.0f,  1.0f ), float2(  0.0f,  1.0f ), float2(  1.0f,  1.0f ),
        float2( -1.0f,  0.0f ), float2(  0.0f,  0.0f ), float2(  1.0f,  0.0f ),
        float2( -1.0f, -1.0f ), float2(  0.0f, -1.0f ), float2(  1.0f, -1.0f )
    };

    const float weights[9] = {
        0.0625f, 0.125f, 0.0625f,
        0.125f,  0.25f,  0.125f,
        0.0625f, 0.125f, 0.0625f
    };

    float3 color = 0.0;

    [unroll]
    for( int i = 0; i < 9; i++ )
    {
        float2 currentUV = IN.txcoord.xy + coords[i] * getPixelSize(texsize);
        color += weights[i] * InputTex.SampleLevel(LinearSampler, currentUV, 0);
    }

    return color;
}

//===========================================================//
// Techniques                                                //
//===========================================================//

technique11 blum <string UIName="Panda Bloom";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Prepass(TextureDownsampled))); } }

technique11 blum1
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurH(TextureColor, 1024.0))); } }

technique11 blum2 <string RenderTarget="RenderTarget1024";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurV(TextureColor, 1024.0))); } }

technique11 blum3
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurH(RenderTarget1024, 512.0))); } }

technique11 blum4 <string RenderTarget="RenderTarget512";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurV(TextureColor, 512.0))); } }

technique11 blum5
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurH(RenderTarget512, 128.0))); } }

technique11 blum6 <string RenderTarget="RenderTarget128";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurV(TextureColor, 128.0))); } }

technique11 blum7
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurH(RenderTarget128, 32.0))); } }

technique11 blum8 <string RenderTarget="RenderTarget32";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_BlurV(TextureColor, 32.0))); } }

technique11 blum9 <string RenderTarget="RenderTargetRGBA64F";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_TexCombine())); } }

technique11 blum10
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_SoftPrepass())); } }

technique11 blum11 <string RenderTarget="RenderTarget128";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(TextureColor, 1024.0))); } }

technique11 blum12 <string RenderTarget="RenderTarget64";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget128, 128.0))); } }

technique11 blum13 <string RenderTarget="RenderTarget32";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget64, 64.0))); } }

technique11 blum14 <string RenderTarget="RenderTarget16";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget32, 32.0))); } }

// Up from here
technique11 blum15 <string RenderTarget="RenderTarget32";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget16, 16.0))); } }

technique11 blum16 <string RenderTarget="RenderTarget64";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget32, 32.0))); } }

technique11 blum17 <string RenderTarget="RenderTarget128";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget64, 64.0))); } }

technique11 blum18 <string RenderTarget="RenderTarget256";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget128, 128.0))); } }

technique11 blum19
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget256, 256.0))); } }

technique11 blum20
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_SoftPostpass())); } }

/*
technique11 Blum1 <string RenderTarget="RenderTarget512";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget1024, 1024.0))); } }

technique11 Blum2 <string RenderTarget="RenderTarget256";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget512, 512.0))); } }

technique11 Blum3 <string RenderTarget="RenderTarget128";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget256, 256.0))); } }

technique11 Blum4 <string RenderTarget="RenderTarget64";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget128, 128.0))); } }

technique11 Blum5 <string RenderTarget="RenderTarget32";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget64, 64.0))); } }

technique11 Blum6 <string RenderTarget="RenderTarget16";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Downsample(RenderTarget32, 32.0))); } }

// Up from here
technique11 Blum7 <string RenderTarget="RenderTarget32";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget16, 16.0))); } }

technique11 Blum8 <string RenderTarget="RenderTarget64";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget32, 32.0))); } }

technique11 Blum9 <string RenderTarget="RenderTarget128";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget64, 64.0))); } }

technique11 Blum10 <string RenderTarget="RenderTarget256";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget128, 128.0))); } }

technique11 Blum11 <string RenderTarget="RenderTarget512";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget256, 256.0))); } }

technique11 Blum12 <string RenderTarget="RenderTarget1024";>
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget512, 512.0))); } }

technique11 Blum13
{ pass p0 { SetVertexShader(CompileShader(vs_5_0, VS_Draw()));
            SetPixelShader (CompileShader(ps_5_0, PS_Upsample(RenderTarget1024, 1024.0))); } }

*/
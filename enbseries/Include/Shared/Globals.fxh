// Header with common decalreations for all ENB files
// It also contains many common fuctions i use

// ENB internals
float4	Timer;           // x = generic timer in range 0..1, period of 16777216 ms (4.6 hours), y = average fps, w = frame time elapsed (in seconds)
float4	ScreenSize;      // x = Width, y = 1/Width, z = Width/Height, w = Height/Width
float	AdaptiveQuality; // changes in range 0..1, 0 means full quality, 1 lowest dynamic quality (0.33, 0.66 are limits for quality levels)
float4	Weather;         // x = current weather index, y = outgoing weather index, z = weather transition, w = time of the day in 24 standart hours.
float4	TimeOfDay1;      // x = dawn, y = sunrise, z = day, w = sunset. Interpolators range from 0..1
float4	TimeOfDay2;      // x = dusk, y = night. Interpolators range from 0..1
float	ENightDayFactor; // changes in range 0..1, 0 means that night time, 1 - day time
float	EInteriorFactor; // changes 0 or 1. 0 means that exterior, 1 - interior
float4  SunDirection;    // Prepass exclusive. Refrence here: https://cdn.discordapp.com/attachments/335788870849265675/532859588203249666/unknown.png
float4  Params01[7];     // skyrimse parameters
float4  ENBParams01;     // x - bloom amount; y - lens amount
float   FieldOfView;

// Pixelsize of current res and also output Resolution
static const float2 PixelSize  = float2(ScreenSize.y, ScreenSize.y * ScreenSize.z);
static const float2 Resolution = float2(ScreenSize.x, ScreenSize.x * ScreenSize.w);

// lagacy way to increase ENB values. Here for completion
float4	tempF1, tempF2, tempF3; //0,1,2,3,4,5,6,7,8,9

// xy = cursor position of previous left click, zw = cursor position of previous right click
float4	tempInfo1;
float4	tempInfo2; 

// All kinds of samplers
SamplerState    PointSampler
{
	Filter = MIN_MAG_MIP_POINT;
	AddressU = Clamp;
	AddressV = Clamp;
};
SamplerState    LinearSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};
SamplerState    WrapSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};
SamplerState    MirrorSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Mirror;
	AddressV = Mirror;
};
SamplerState    BorderSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Border;
	AddressV = Border;
};

// Generic Vertex Shader
struct VS_INPUT
{
    float3 pos     : POSITION;
    float2 txcoord : TEXCOORD0;
};
struct VS_OUTPUT
{
    float4 pos     : SV_POSITION;
    float2 txcoord : TEXCOORD0;
};

VS_OUTPUT VS_Draw(VS_INPUT IN)
{
    VS_OUTPUT OUT;
    OUT.pos = float4(IN.pos.xyz, 1.0);
    OUT.txcoord.xy = IN.txcoord.xy;
    return OUT;
}

// Calculate perceived luminance color by using the ITU-R BT standards.
// Original code by TreyM
// Luma Coefficients
#define Rec709      0
#define Rec709_5    1
#define Rec601      2
#define Rec2020     3
#define Lum333      4

float GetLuma(in float3 color, int btspec)
{
    static const float3 LumaCoeff[5] =
    {
        // 0: HD TV - Rec.709
        float3(0.2126, 0.7152f, 0.0722),
        // 1: HD TV - Rec.709-5
        float3(0.212395, 0.701049, 0.086556),
        // 2: CRT TV - Rec.601
        float3(0.299, 0.587, 0.114),
        // 3: HDR Spec - Rec.2020
        float3(0.2627, 0.6780, 0.0593),
        // 4: Incorrect Equal Weighting
        float3(0.3333, 0.3333, 0.3333)
    };

    return dot(color.rgb, LumaCoeff[btspec]);
}

// Depth Linearization (Thanks to Marty)
float getLinearizedDepth(float2 coord)
{
    float depth = TextureDepth.Sample(PointSampler, coord);
    depth *= rcp(mad(depth,-2999.0,3000.0));
    return depth;
}

// Max function for float3s
float max3(float3 input)
{
	return max(input.x, max(input.y, input.z));
}

float min3(float3 input)
{
	return min(input.x, min(input.y, input.z));
}

// Triangular Dither
// By The Sandvich Maker
#define remap(v, a, b) (((v) - (a)) / ((b) - (a)))

float rand21(float2 uv)
{
    float2 noise = frac(sin(dot(uv, float2(12.9898, 78.233) * 2.0)) * 43758.5453);
    return (noise.x + noise.y) * 0.5;
}

float rand11(float x)
{
    return frac(x * 0.024390243);
}

float permute(float x)
{
    return ((34.0 * x + 1.0) * x) % 289.0;
}

float3 triDither(float3 color, float2 uv, float timer, int BIT_DEPTH)
{
    float bitstep = pow(2.0, BIT_DEPTH) - 1.0;
    float lsb = 1.0 / bitstep;
    float lobit = 0.5 / bitstep;
    float hibit = (bitstep - 0.5) / bitstep;

    float3 m = float3(uv, rand21(uv + timer)) + 1.0;
    float h = permute(permute(permute(m.x) + m.y) + m.z);

    float3 noise1, noise2;
    noise1.x = rand11(h); h = permute(h);
    noise2.x = rand11(h); h = permute(h);
    noise1.y = rand11(h); h = permute(h);
    noise2.y = rand11(h); h = permute(h);
    noise1.z = rand11(h); h = permute(h);
    noise2.z = rand11(h);

    float3 lo = saturate(remap(color.xyz, 0.0, lobit));
    float3 hi = saturate(remap(color.xyz, 1.0, hibit));
    float3 uni = noise1 - 0.5;
    float3 tri = noise1 - noise2;

    return float3(
        lerp(uni.x, tri.x, min(lo.x, hi.x)),
        lerp(uni.y, tri.y, min(lo.y, hi.y)),
        lerp(uni.z, tri.z, min(lo.z, hi.z))) * lsb;
}

// Calculates the edges of the supplied texture.
// Tipp: Multiply the pixelsize to get T H I C C lines.
struct EdgeData
{
    float Mid, Left, Right, Bottom, Top; // Directions
    float Edges;
    float Depths[4];
};

float2    EdgeOffsets[4] =
{
    float2( 1.0,  0.0), // Right
    float2(-1.0,  0.0), // Left
    float2( 0.0,  1.0), // Bottom
    float2( 0.0, -1.0)  // Top
};

float getEdges(Texture2D InputTex, float2 coord, float2 Pixelsize)
{
    EdgeData Edge;

    for (int i = 0; i < 4; i++)
    {
        Edge.Depths[i] = InputTex.Sample(PointSampler, coord + EdgeOffsets[i] * Pixelsize);
    }

    Edge.Mid     = InputTex.Sample(PointSampler, coord);
    Edge.Right   = abs(Edge.Mid - Edge.Depths[0]);
    Edge.Left    = abs(Edge.Mid - Edge.Depths[1]);
    Edge.Bottom  = abs(Edge.Mid - Edge.Depths[2]);
    Edge.Top     = abs(Edge.Mid - Edge.Depths[3]);
    Edge.Edges   = Edge.Right + Edge.Left + Edge.Bottom + Edge.Top;

    return Edge.Edges;
}
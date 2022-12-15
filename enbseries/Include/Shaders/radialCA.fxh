// Radial CA by Barrel Distortion
// Original code by kingeric1992

float2 Distortion( float2 coord, float curve)
{
    float  Radius = length(coord);
    return pow(2 * Radius, curve) * coord / Radius * RadialCA * 0.01 * 0.1;
}

//.rgb == color, .a == offset
float4 Spectrum[7] =
{
    float4(1.0, 0.0, 0.0,  1.0),//red
    float4(1.0, 0.5, 0.0,  0.7),//orange
    float4(1.0, 1.0, 0.0,  0.3),//yellow
    float4(0.0, 1.0, 0.0,  0.0),//green
    float4(0.0, 0.0, 1.0, -0.6),//blue
    float4(0.3, 0.0, 0.5, -0.8),//indigo
    float4(0.1, 0.0, 0.2, -1.0) //purple
};

float3 SampleBlurredImage(float3 Original, float2 coord)
{
    float2 pixelSize = float2(1, ScreenSize.z);
    float2 Offset    = (coord - 0.5) * pixelSize;       //length to center
           Offset    = Distortion(Offset, barrelPower) / pixelSize * RadialCA * 0.1;
    float  weight[11]= {0.082607, 0.080977, 0.076276, 0.069041, 0.060049, 0.050187, 0.040306, 0.031105, 0.023066, 0.016436, 0.011254};
    float3 CA        = Original * weight[0];

    for(int i=1; i<11; i++)
    {
        CA += TextureColor.Sample(LinearSampler, coord + Offset * i) * weight[i];
        CA += TextureColor.Sample(LinearSampler, coord - Offset * i) * weight[i];
    }

    return CA;
}

float3 LensCA(float2 coord) : SV_Target
{
    float3 Original = TextureColor.Sample(PointSampler, coord);
    float2 pixelSize = float2(1, ScreenSize.z);
    float2 Offset    = (coord - 0.5) * pixelSize;       //length to center
           Offset    = Distortion(Offset, barrelPower) / pixelSize;
    float3 Color;

    for(int i=0; i<7; i++)
    {
        Color.rgb = max(Color.rgb, TextureColor.Sample(LinearSampler, coord - Offset * Spectrum[i].a).rgb * Spectrum[i].rgb);
    }

    return Color;
}

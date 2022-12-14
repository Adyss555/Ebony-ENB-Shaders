// LUT code by kingeric1992

// Functions
float3 Lut(float3 colorIN, Texture2D lutTexIn, float2 lutSize)
{
    float2 CLut_pSize = 1.0 / lutSize;
    float4 CLut_UV;
    colorIN    = saturate(colorIN) * ( lutSize.y - 1.0);
    CLut_UV.w  = floor(colorIN.b);
    CLut_UV.xy = (colorIN.rg + 0.5) * CLut_pSize;
    CLut_UV.x += CLut_UV.w * CLut_pSize.y;
    CLut_UV.z  = CLut_UV.x + CLut_pSize.y;
    return       lerp(lutTexIn.SampleLevel(LinearSampler, CLut_UV.xy, 0).rgb,
                      lutTexIn.SampleLevel(LinearSampler, CLut_UV.zy, 0).rgb, colorIN.b - CLut_UV.w);
}

//function overload
float3 Lut(float3 colorIN, Texture2D lutTexIn)
{
    float2 lutsize;
    lutTexIn.GetDimensions(lutsize.x, lutsize.y);
    return Lut(colorIN, lutTexIn, lutsize);
}

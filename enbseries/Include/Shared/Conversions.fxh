// Colorspace conversions
// Souces: 
// http://www.chilliant.com/rgb2hsv.html
// http://enbseries.enbdev.com/forum/viewtopic.php?t=6239

// Converting pure hue to RGB
float3 HUEtoRGB(in float H)
{
    float R = abs(H * 6 - 3) - 1;
    float G = 2 - abs(H * 6 - 2);
    float B = 2 - abs(H * 6 - 4);
    return saturate(float3(R,G,B));
}

// Converting RGB to hue/chroma/value
float Epsilon = 1e-10;

float3 RGBtoHCV(in float3 RGB)
{
    // Based on work by Sam Hocevar and Emil Persson
    float4 P = (RGB.g < RGB.b) ? float4(RGB.bg, -1.0, 2.0/3.0) : float4(RGB.gb, 0.0, -1.0/3.0);
    float4 Q = (RGB.r < P.x) ? float4(P.xyw, RGB.r) : float4(RGB.r, P.yzx);
    float C = Q.x - min(Q.w, Q.y);
    float H = abs((Q.w - Q.y) / (6 * C + Epsilon) + Q.z);
    return float3(H, C, Q.x);
}

// Converting HSV to RGB
float3 HSVtoRGB(in float3 HSV)
{
    float3 RGB = HUEtoRGB(HSV.x);
    return ((RGB - 1) * HSV.y + 1) * HSV.z;
}

// Converting HSL to RGB
float3 HSLtoRGB(in float3 HSL)
{
    float3 RGB = HUEtoRGB(HSL.x);
    float C = (1 - abs(2 * HSL.z - 1)) * HSL.y;
    return (RGB - 0.5) * C + HSL.z;
}

// Converting HCY to RGB
// The weights of RGB contributions to luminance.
// Should sum to unity.
float3 HCYwts = float3(0.299, 0.587, 0.114);

float3 HCYtoRGB(in float3 HCY)
{
    float3 RGB = HUEtoRGB(HCY.x);
    float Z = dot(RGB, HCYwts);
    if (HCY.z < Z)
    {
        HCY.y *= HCY.z / Z;
    }
    else if (Z < 1)
    {
        HCY.y *= (1 - HCY.z) / (1 - Z);
    }
    return (RGB - Z) * HCY.y + HCY.z;
}

//Converting HCL to RGB
float HCLgamma = 3;
float HCLy0 = 100;
float HCLmaxL = 0.530454533953517; // == exp(HCLgamma / HCLy0) - 0.5
float PI = 3.1415926536;

float3 HCLtoRGB(in float3 HCL)
{
    float3 RGB = 0;
    if (HCL.z != 0)
    {
      float H = HCL.x;
      float C = HCL.y;
      float L = HCL.z * HCLmaxL;
      float Q = exp((1 - C / (2 * L)) * (HCLgamma / HCLy0));
      float U = (2 * L - C) / (2 * Q - 1);
      float V = C / Q;
      float A = (H + min(frac(2 * H) / 4, frac(-2 * H) / 8)) * PI * 2;
      float T;
      H *= 6;
      if (H <= 0.999)
      {
        T = tan(A);
        RGB.r = 1;
        RGB.g = T / (1 + T);
      }
      else if (H <= 1.001)
      {
        RGB.r = 1;
        RGB.g = 1;
      }
      else if (H <= 2)
      {
        T = tan(A);
        RGB.r = (1 + T) / T;
        RGB.g = 1;
      }
      else if (H <= 3)
      {
        T = tan(A);
        RGB.g = 1;
        RGB.b = 1 + T;
      }
      else if (H <= 3.999)
      {
        T = tan(A);
        RGB.g = 1 / (1 + T);
        RGB.b = 1;
      }
      else if (H <= 4.001)
      {
        RGB.g = 0;
        RGB.b = 1;
      }
      else if (H <= 5)
      {
        T = tan(A);
        RGB.r = -1 / T;
        RGB.b = 1;
      }
      else
      {
        T = tan(A);
        RGB.r = 1;
        RGB.b = -T;
      }
      RGB = RGB * V + U;
    }
    return RGB;
}

// Converting RGB to HSV
float3 RGBtoHSV(in float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float S = HCV.y / (HCV.z + Epsilon);
    return float3(HCV.x, S, HCV.z);
}

// Converting RGB to HSL
float3 RGBtoHSL(in float3 RGB)
{
    float3 HCV = RGBtoHCV(RGB);
    float L = HCV.z - HCV.y * 0.5;
    float S = HCV.y / (1 - abs(L * 2 - 1) + Epsilon);
    return float3(HCV.x, S, L);
}

//Converting RGB to HCY
float3 RGBtoHCY(in float3 RGB)
{
    // Corrected by David Schaeffer
    float3 HCV = RGBtoHCV(RGB);
    float Y = dot(RGB, HCYwts);
    float Z = dot(HUEtoRGB(HCV.x), HCYwts);
    if (Y < Z)
    {
      HCV.y *= Z / (Epsilon + Y);
    }
    else
    {
      HCV.y *= (1 - Z) / (Epsilon + 1 - Y);
    }
    return float3(HCV.x, HCV.y, Y);
}

// Converting RGB to HCL
float3 RGBtoHCL(in float3 RGB)
{
    float3 HCL;
    float H = 0;
    float U = min(RGB.r, min(RGB.g, RGB.b));
    float V = max(RGB.r, max(RGB.g, RGB.b));
    float Q = HCLgamma / HCLy0;
    HCL.y = V - U;
    if (HCL.y != 0)
    {
      H = atan2(RGB.g - RGB.b, RGB.r - RGB.g) / PI;
      Q *= U / V;
    }
    Q = exp(Q);
    HCL.x = frac(H / 2 - min(frac(H), frac(-H)) / 6);
    HCL.y *= Q;
    HCL.z = lerp(-U, V, Q) / (HCLmaxL * 2);
    return HCL;
}

// Linear to sRGB conversion
float3 LinearTosRGB(in float3 color)
{
    float3 x = color * 12.92f;
    float3 y = 1.055f * pow(saturate(color), 1.0f / 2.4f) - 0.055f;

    float3 clr = color;
    clr.r = color.r < 0.0031308f ? x.r : y.r;
    clr.g = color.g < 0.0031308f ? x.g : y.g;
    clr.b = color.b < 0.0031308f ? x.b : y.b;

    return clr;
}

float3 SRGBToLinear(in float3 color)
{
    float3 x = color / 12.92f;
    float3 y = pow(max((color + 0.055f) / 1.055f, 0.0f), 2.4f);

    float3 clr = color;
    clr.r = color.r <= 0.04045f ? x.r : y.r;
    clr.g = color.g <= 0.04045f ? x.g : y.g;
    clr.b = color.b <= 0.04045f ? x.b : y.b;

    return clr;
}

float3 lin2srgb_fast(float3 color)
{
    return sqrt(color);
}

float3 srgb2lin_fast(float3 color)
{
    return color * color;
}


float3 rgb2xyz(float3 color)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
        0.4124564, 0.3575761, 0.1804375,
        0.2126729, 0.7151522, 0.0721750,
        0.0193339, 0.1191920, 0.9503041
    );
    return mul(mat, color);
}

float3 xyz2rgb(float3 color)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
         3.2404542, -1.5371385, -0.4985314,
        -0.9692660,  1.8760108,  0.0415560,
         0.0556434, -0.2040259,  1.0572252
    );
    return mul(mat, color);
}

float3 xyz2lms(float3 color)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
         0.3592, 0.6976, -0.0358,
        -0.1922, 1.1004,  0.0755,
         0.0070, 0.0749,  0.8434
    );
    return mul(mat, color);
}

float3 lms2xyz(float3 color)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
         2.0702, -1.3265,  0.2066,
         0.3650,  0.6805, -0.0454,
        -0.0496, -0.0494,  1.1879
    );
    return mul(mat, color);
}

static const float PQ_Const_N = (2610.0 / 4096.0 / 4.0);
static const float PQ_Const_M = (2523.0 / 4096.0 * 128.0);
static const float PQ_Const_C1 = (3424.0 / 4096.0);
static const float PQ_Const_C2 = (2413.0 / 4096.0 * 32.0);
static const float PQ_Const_C3 = (2392.0 / 4096.0 * 32.0);

float3 linear2pq(float3 lin, const float maxPq)
{
    lin /= maxPq;

    float3 colToPow = pow(lin, PQ_Const_N);
    float3 numerator = PQ_Const_C1 + PQ_Const_C2 * colToPow;
    float3 denominator = 1.0 + PQ_Const_C3 * colToPow;
    return pow(numerator / denominator, PQ_Const_M);
}

float3 pq2linear(float3 lin, const float maxPq)
{
    float3 colToPow = pow(lin, 1.0 / PQ_Const_M);
    float3 numerator = max(colToPow - PQ_Const_C1, 0.0);
    float3 denominator = PQ_Const_C2 - PQ_Const_C3 * colToPow;
    lin = pow(numerator / denominator, 1.0 / PQ_Const_N);

    return lin * maxPq;
}

float3 rgb2lms(float3 rgb)
{
    static const float3x3 mat = float3x3(
        // wikipedia values
        // 0.412109375,    0.52392578125,  0.06396484375,
        // 0.166748046875, 0.720458984375, 0.1103515625,
        // 0.024169921875, 0.075439453125, 0.900390625

        // frostbyte values
        0.29582280029999997,  0.62306443624,      0.08114154322,
        0.15621084853,        0.7272263504600001, 0.11648924205,
        0.035122606269999995, 0.15659446528,      0.80815544794
    );
    return mul(mat, rgb);
}

float3 lms2rgb(float3 lms)
{
    static const float3x3 mat = float3x3(
        // wikipedia values
        //  3.4367654503826586,  -2.5058469852729397,  0.06296374439889145,
        // -0.7914551947720561,   1.9831215506221327, -0.18682475050187772,
        // -0.02594363459959811, -0.09888983394799836, 1.1245920382889343

        // frostbyte values
         6.172012299588382,  -5.319658410674432,   0.14709592537669258,
        -1.3238950004228818,  2.5602005272135897, -0.23610919904326724,
        -0.0117087971603403, -0.26489082671563907, 1.2767432356374429
    );
    return mul(mat, lms);
}

float3 lms2ictcp(float3 lms)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
        0.5000,  0.5000,  0.0000,
        1.6137, -3.3234,  1.7097,
        4.3780, -4.2455, -0.1325
    );
    return mul(mat, lms);
}

float3 ictcp2lms(float3 ictcp)
{
    static const float3x3 mat = float3x3(
        // frostbyte values
        1.0,  0.0086051,  0.1111035,
        1.0, -0.0086051, -0.1111035,
        1.0,  0.5600488, -0.3206370
    );
    return mul(mat, ictcp);
}

float3 rgb2ictcp(float3 col)
{
    col = rgb2lms(col);
    col = linear2pq(max(0.0, col), 100.0);
    col = lms2ictcp(col);

    return col;
}

float3 ictcp2rgb(float3 col)
{
    col = ictcp2lms(col);
    col = pq2linear(col, 100.0);
    col = lms2rgb(col);

    return col;
}
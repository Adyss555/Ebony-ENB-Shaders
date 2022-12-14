// FILM GRAIN SHADER ///////////////////////////////
////////////////////////////////////////////////////
// By martinsh                                    //
// ported to ENB by roxahris                      //
// Modified for correct film response, LOG input  //
// and Soft Light blending by TreyM               //
////////////////////////////////////////////////////

// LOG MODE //////////////////////////////////////
// Input is LOG? /////////////////////////////
#define INPUT_LOG 0
#define GRAIN_CURVE true

// FUNCTIONS /////////////////////////////////////
float4 rnm(in float2 tc)
{
    float noise = sin(dot(float3(tc.x, tc.y, Timer.x*16777216), float3(12.9898, 78.233, 0.0025216))) * 43758.5453;

    float noiseR =  frac(noise)*2.0-1.0;
    float noiseG =  frac(noise*1.2154)*2.0-1.0;
    float noiseB =  frac(noise*1.3453)*2.0-1.0;
    float noiseA =  frac(noise*1.3647)*2.0-1.0;

    return float4(noiseR,noiseG,noiseB,noiseA);
}

float fade(in float t)
{
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float pnoise3D(in float3 p)
{
    static const float permTexUnit = 1.0/256.0;        // Perm texture texel-size
    static const float permTexUnitHalf = 0.5/256.0;    // Half perm texture texel-size
    float3 pi = permTexUnit*floor(p)+permTexUnitHalf; // Integer part, scaled so +1 moves permTexUnit texel
    // and offset 1/2 texel to sample texel centers
    float3 pf = frac(p);     // Fractional part for interpolation

    // Noise contributions from (x=0, y=0), z=0 and z=1
    float perm00 = rnm(pi.xy).a ;
    float3  grad000 = rnm(float2(perm00, pi.z)).rgb * 4.0 - 1.0;
    float n000 = dot(grad000, pf);
    float3  grad001 = rnm(float2(perm00, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
    float n001 = dot(grad001, pf - float3(0.0, 0.0, 1.0));

    // Noise contributions from (x=0, y=1), z=0 and z=1
    float perm01 = rnm(pi.xy + float2(0.0, permTexUnit)).a ;
    float3  grad010 = rnm(float2(perm01, pi.z)).rgb * 4.0 - 1.0;
    float n010 = dot(grad010, pf - float3(0.0, 1.0, 0.0));
    float3  grad011 = rnm(float2(perm01, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
    float n011 = dot(grad011, pf - float3(0.0, 1.0, 1.0));

    // Noise contributions from (x=1, y=0), z=0 and z=1
    float perm10 = rnm(pi.xy + float2(permTexUnit, 0.0)).a ;
    float3  grad100 = rnm(float2(perm10, pi.z)).rgb * 4.0 - 1.0;
    float n100 = dot(grad100, pf - float3(1.0, 0.0, 0.0));
    float3  grad101 = rnm(float2(perm10, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
    float n101 = dot(grad101, pf - float3(1.0, 0.0, 1.0));

    // Noise contributions from (x=1, y=1), z=0 and z=1
    float perm11 = rnm(pi.xy + float2(permTexUnit, permTexUnit)).a ;
    float3  grad110 = rnm(float2(perm11, pi.z)).rgb * 4.0 - 1.0;
    float n110 = dot(grad110, pf - float3(1.0, 1.0, 0.0));
    float3  grad111 = rnm(float2(perm11, pi.z + permTexUnit)).rgb * 4.0 - 1.0;
    float n111 = dot(grad111, pf - float3(1.0, 1.0, 1.0));

    // Blend contributions along x
    float4 n_x = lerp(float4(n000, n001, n010, n011), float4(n100, n101, n110, n111), fade(pf.x));

    // Blend contributions along y
    float2 n_xy = lerp(n_x.xy, n_x.zw, fade(pf.y));

    // Blend contributions along z
    float n_xyz = lerp(n_xy.x, n_xy.y, fade(pf.z));

    // We're done, return the final noise value.
    return n_xyz;
}

//2d coordinate orientation thing
float2 coordRot(in float2 tc, in float angle)
{
    #define aspectr ScreenSize.z
    float rotX = ((tc.x*2.0-1.0)*aspectr*cos(angle)) - ((tc.y*2.0-1.0)*sin(angle));
    float rotY = ((tc.y*2.0-1.0)*cos(angle)) + ((tc.x*2.0-1.0)*aspectr*sin(angle));
    rotX = ((rotX/aspectr)*0.5+0.5);
    rotY = rotY*0.5+0.5;
    return float2(rotX,rotY);
    #undef aspectr
}

// 35MM Film Grain ///////////////////////////
float3 GrainPass(float2 position, float3 col)
{
    // Initial Setup /////////////////////////
    float height = ScreenSize.x/ScreenSize.z;
    float width  = ScreenSize.x;
    float3 grey = 0.5;

// Grain Profile Arrays //////////////////

    // Grain Amount //////////////////////
    // Red ///////////////////////////
    float grainamountR[3] =
    {
        // Fine //////////////////////
        0.33,
        // Medium ////////////////////
        0.2,
        // Coarse ////////////////////
        0.2
    };
    // Green /////////////////////////
    float grainamountG[3] =
    {
        // Fine //////////////////////
        0.33,
        // Medium ////////////////////
        0.3,
        // Coarse ////////////////////
        0.3
    };
    // Blue //////////////////////////
    float grainamountB[3] =
    {
        // Fine //////////////////////
        0.33,
        // Medium ////////////////////
        0.4,
        // Coarse ////////////////////
        0.6
    };

// Grain Size ////////////////////////
    // Red ///////////////////////////
    float grainsizeR[3] =
    {
        // Fine //////////////////////
        1.5,
        // Medium ////////////////////
        2.0,
        // Coarse ////////////////////
        2.2
    };
    // Green /////////////////////////
    float grainsizeG[3] =
    {
        // Fine //////////////////////
        1.75,
        // Medium ////////////////////
        2.2,
        // Coarse ////////////////////
        2.4
    };
    // Blue //////////////////////////
    float grainsizeB[3] =
    {
        // Fine //////////////////////
        2.0,
        // Medium ////////////////////
        2.35,
        // Coarse ////////////////////
        2.6
    };

    // Setup the Grain Randomization /////////
    float3 rotOffset = float3(1.425,3.892,5.835);
    float2 rotCoords  = coordRot(position, Timer.x*16777216 + (rotOffset.z - rotOffset.y));
    float2 rotCoordsR = coordRot(position, Timer.x*16777216 + rotOffset.x);
    float2 rotCoordsG = coordRot(position, Timer.x*16777216 + rotOffset.y);
    float2 rotCoordsB = coordRot(position, Timer.x*16777216 + rotOffset.z);
    float2 rot = rotCoords*float2(width/1.0,height/1.0);

    // Generate the Grain for Each Color /////
    float pNoise = pnoise3D(float3(rot.x,rot.y,0.0));
    float3 noise = float3(pNoise, pNoise, pNoise);
    noise.r = lerp(0.0,pnoise3D(float3(rotCoordsR*float2(width/grainsizeR[grainRoughness - 1],height/grainsizeR[grainRoughness - 1]),0.0)),grainamountR[grainRoughness - 1]);
    noise.g = lerp(0.0,pnoise3D(float3(rotCoordsG*float2(width/grainsizeG[grainRoughness - 1],height/grainsizeG[grainRoughness - 1]),1.0)),grainamountG[grainRoughness - 1]);
    noise.b = lerp(0.0,pnoise3D(float3(rotCoordsB*float2(width/grainsizeB[grainRoughness - 1],height/grainsizeB[grainRoughness - 1]),2.0)),grainamountB[grainRoughness - 1]);

    // Generate Mask for Filmic Response /////
    float lum;
    float luminance;
    float3 lumcoeff = float3(0.299,0.587,0.114);
    luminance = lerp(0.33, dot(col, lumcoeff), (GRAIN_CURVE * 1.0));
    lum = lerp(0.0, smoothstep(0.33, 0.0, luminance), (GRAIN_CURVE * 1.0));
    lum += luminance - 0.1;

    // Combine and Blend the Grain ///////////
    noise = lerp(noise, dot(noise, lumcoeff), 0.5);
    noise = lerp(noise, 0.0, pow(lum, 3.0));
    noise = noise * (grainAmount * 0.004);
    grey += noise;

    // Desaturate Grain if Using B&W //////////
    grey = dot(grey, lumcoeff);
    col = BlendSoftLight(col, grey);

    return float4(col,1.0);
}

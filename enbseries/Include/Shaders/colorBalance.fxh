/*
    Description : PD80 04 Color Balance for Reshade https://reshade.me/
    Author      : prod80 (Bas Veth)
    License     : MIT, Copyright (c) 2020 prod80
    MIT License
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
*/

#define ES_RGB   float3( 1.0 - float3( 0.299, 0.587, 0.114 ))
#define ES_CMY   float3( dot( ES_RGB.yz, 0.5 ), dot( ES_RGB.xz, 0.5 ), dot( ES_RGB.xy, 0.5 ))

float3 curve( float3 x )
{
    return x * x * ( 3.0f - 2.0f * x );
}

float3 ColorBalance( float3 c, float3 shadows, float3 midtones, float3 highlights )
{
    // For highlights
    float luma = GetLuma(c, Lum333);
    
    // Determine the distribution curves between shadows, midtones, and highlights
    float3 dist_s; float3 dist_h;
    
    // Clear cutoff between shadows and highlights
    // Maximizes precision at the loss of harsher transitions between contrasts
    // Curves look like:
    // Shadows                   Highlights             Midtones
    // ‾‾‾—_    	                            _—‾‾‾         _——‾‾‾——_
    //      ‾‾——__________       __________——‾‾         ___—‾         ‾—___
    // 0.0.....0.5.....1.0       0.0.....0.5.....1.0    0.0.....0.5.....1.0

    dist_s.xyz  = curve( max( 1.0f - c.xyz * 2.0f, 0.0f ));
    dist_h.xyz  = curve( max(( c.xyz - 0.5f ) * 2.0f, 0.0f ));

    // Get luminosity offsets
    float3  s_rgb    = shadows > 0.0f     ? ES_RGB * shadows      : ES_CMY * abs( shadows );
    float3  m_rgb    = midtones > 0.0f    ? ES_RGB * midtones     : ES_CMY * abs( midtones );
    float3  h_rgb    = highlights > 0.0f  ? ES_RGB * highlights   : ES_CMY * abs( highlights );

    float3 mids  = saturate( 1.0f - dist_s.xyz - dist_h.xyz );
    float3 highs = dist_h.xyz * ( highlights.xyz * h_rgb.xyz * ( 1.0f - luma ));
    float3 newc  = c.xyz * ( dist_s.xyz * shadows.xyz * s_rgb.xyz + mids.xyz * midtones.xyz * m_rgb.xyz ) * ( 1.0f - c.xyz ) + highs.xyz;
    return saturate( c.xyz + newc.xyz );
}
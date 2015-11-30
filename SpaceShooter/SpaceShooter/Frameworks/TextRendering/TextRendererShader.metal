//
//  Shaders.metal
//  TextRendering
//
//  Created by Warren Moore on 2/6/15.
//  Copyright (c) 2015 Metal By Example. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex
{
    float4 position [[ attribute(0) ]];
    float2 texCoords [[ attribute(1) ]];
};

struct TransformedVertex
{
    float4 position [[position]];
    float2 texCoords;
};

#pragma pack(push)
#pragma pack(1)

struct Uniforms
{
    float4x4 viewProjectionMatrix;
    float4x4 modelMatrix;
    float4 color;
};

#pragma pack(pop)

vertex TransformedVertex text_vertex(const Vertex vertexIn [[ stage_in ]],
                                     constant Uniforms &uniforms [[buffer(1)]])
{
    TransformedVertex outVert;
    outVert.position = uniforms.viewProjectionMatrix * uniforms.modelMatrix * float4(vertexIn.position);
    outVert.texCoords = vertexIn.texCoords;
    return outVert;
}

fragment half4 text_fragment(TransformedVertex vert [[stage_in]],
                             constant Uniforms &uniforms [[buffer(0)]],
                             sampler samplr [[sampler(0)]],
                             texture2d<float, access::sample> texture [[texture(0)]])
{
    float4 color = uniforms.color;
    // Outline of glyph is the isocontour with value 50%
    float edgeDistance = 0.5;
    // Sample the signed-distance field to find distance from this fragment to the glyph outline
    float sampleDistance = texture.sample(samplr, vert.texCoords).r;
    // Use local automatic gradients to find anti-aliased anisotropic edge width, cf. Gustavson 2012
    float edgeWidth = 0.75 * length(float2(dfdx(sampleDistance), dfdy(sampleDistance)));
    // Smooth the glyph edge by interpolating across the boundary in a band with the width determined above
    float insideness = smoothstep(edgeDistance - edgeWidth, edgeDistance + edgeWidth, sampleDistance);
    return half4(color.r, color.g, color.b, insideness * color.a);
}

//
//  HighPassFilterShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
#include "FilterShared.h"

struct ProjectedVertex {
    float4 position [[ position ]];
    float2 texCoords;
};

vertex ProjectedVertex highPassFilterVertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]]) {
    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * float4(vertexIn.position, 1);
    projectedVertex.texCoords = vertexIn.texCoords;
    return projectedVertex;
}

fragment half4 highPassFilterFragment(
        ProjectedVertex vert [[ stage_in ]],
        sampler samplr [[ sampler(0) ]],
        texture2d<float, access::sample> texture [[ texture(0) ]]) {
    float4 sample = texture.sample(samplr, vert.texCoords);
    float intensity = dot(sample.rgb, float3(0.299, 0.587, 0.114));
    return intensity > 0.25 ? half4(sample.r, sample.g, sample.b, sample.a) : half4(0);
}
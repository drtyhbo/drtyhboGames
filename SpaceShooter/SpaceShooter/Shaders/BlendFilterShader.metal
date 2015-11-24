//
//  BlendFilterShader.metal
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

vertex ProjectedVertex blendFilterVertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]]) {
    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * float4(vertexIn.position, 1);
    projectedVertex.texCoords = vertexIn.texCoords;
    return projectedVertex;
}

fragment float4 blendFilterFragment(
        ProjectedVertex vert [[ stage_in ]],
        sampler samplr [[ sampler(0) ]],
        texture2d<float, access::sample> texture [[ texture(0) ]]) {
    float4 sample =  texture.sample(samplr, vert.texCoords);
    return sample.r < 0.01 && sample.g <= 0.01 && sample.b <= 0.01 ? float4(0) : sample;
}
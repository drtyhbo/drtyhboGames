//
//  GaussianFilterShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
#import "FilterShared.h"

struct ProjectedVertex {
    float4 position [[ position ]];
    float2 blurCoordinate0;
    float2 blurCoordinate1;
    float2 blurCoordinate2;
    float2 blurCoordinate3;
    float2 blurCoordinate4;
};

vertex ProjectedVertex gaussianFilterVertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]],
        const device float2 &stepOffsets [[ buffer(2) ]]) {
    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * float4(vertexIn.position, 1);

    projectedVertex.blurCoordinate0 = vertexIn.texCoords;
    projectedVertex.blurCoordinate1 = vertexIn.texCoords + stepOffsets * 1.407333;
    projectedVertex.blurCoordinate2 = vertexIn.texCoords - stepOffsets * 1.407333;
    projectedVertex.blurCoordinate3 = vertexIn.texCoords + stepOffsets * 3.294215;
    projectedVertex.blurCoordinate4 = vertexIn.texCoords - stepOffsets * 3.294215;

    return projectedVertex;
}

fragment float4 gaussianFilterFragment(
        ProjectedVertex vert [[ stage_in ]],
        sampler samplr [[ sampler(0) ]],
        texture2d<float, access::sample> texture [[ texture(0) ]]) {
    float4 sum = float4(0);
    sum += texture.sample(samplr, vert.blurCoordinate0) * 0.204164;
    sum += texture.sample(samplr, vert.blurCoordinate1) * 0.304005;
    sum += texture.sample(samplr, vert.blurCoordinate2) * 0.304005;
    sum += texture.sample(samplr, vert.blurCoordinate3) * 0.093913;
    sum += texture.sample(samplr, vert.blurCoordinate4) * 0.093913;

    return sum;
}
//
//  SpriteShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float2 texCoords [[ attribute(1) ]];
};

struct SharedUniforms {
    float4x4 projectionMatrix;
};

struct PerInstanceUniforms {
    float4x4 modelViewMatrix;
};

struct ProjectedVertex {
    float4 position [[ position ]];
    float2 texCoords;
};

vertex ProjectedVertex sprite_vertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]],
        const device PerInstanceUniforms* perInstanceUniforms [[ buffer(2) ]],
        unsigned int iid [[ instance_id ]]) {
    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * perInstanceUniforms[iid].modelViewMatrix * float4(vertexIn.position, 1);
    projectedVertex.texCoords = vertexIn.texCoords;

    return projectedVertex;
}

fragment half4 sprite_fragment(ProjectedVertex vert [[ stage_in ]],
        sampler samplr [[ sampler(0) ]],
        texture2d<float, access::sample> texture [[ texture(0) ]]) {
    float4 sample = texture.sample(samplr, vert.texCoords);
    return half4(sample.r, sample.g, sample.b, sample.a);
}
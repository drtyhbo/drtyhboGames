//
//  Shaders.metal
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
#include "Shared.h"

using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct PerInstanceUniforms {
    float4x4 modelViewMatrix;
    float4x4 normalMatrix;
    float4 color;
};

struct ProjectedVertex {
    float4 position [[ position ]];
    float4 color;
};

float4 computeLighting(const float3 unitNormal, const float4 color);

float4 computeLighting(const float3 unitNormal, const float4 color) {
    float diffuseIntensity = saturate(0.25 + dot(unitNormal, float3(0, 0, 1)));
    return float4(diffuseIntensity * color.r, diffuseIntensity * color.g, diffuseIntensity * color.b, color.a);
}

vertex ProjectedVertex basic_vertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]],
        const device PerInstanceUniforms* perInstanceUniforms [[ buffer(2) ]],
        unsigned int iid [[ instance_id ]]) {
    float4 position = float4(vertexIn.position, 1);
    float4 normal = float4(vertexIn.normal, 0);

    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * perInstanceUniforms[iid].modelViewMatrix * position;
    projectedVertex.color = computeLighting(normalize(float3(perInstanceUniforms[iid].normalMatrix * normal)), perInstanceUniforms[iid].color);

    return projectedVertex;
}

fragment half4 basic_fragment(ProjectedVertex vert [[ stage_in ]]) {
    return half4(vert.color.r, vert.color.g, vert.color.b, vert.color.a);
}
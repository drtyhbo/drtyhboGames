//
//  GridShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/25/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
#include "Shared.h"

using namespace metal;

struct GridUniforms {
    int numLights;
};

struct VertexIn {
    float2 position [[ attribute(0) ]];
};

struct ProjectedVertex {
    float4 position [[ position ]];
    float4 color;
};

struct Light {
    packed_float3 position;
    packed_float3 color;
    float intensity;
};

float3 computeLightContribution(Light light, float3 position);

float3 computeLightContribution(Light light, float3 position) {
    float2 lightPosition2 = float2(light.position[0], light.position[1]);
    float2 position2 = float2(position[0], position[1]);
    float distance = length(lightPosition2 - position2);
    float intensity = min(0.5, light.intensity / (distance * distance));
    return float3(light.color[0] * intensity, light.color[1] * intensity, light.color[2] * intensity);
}

vertex ProjectedVertex grid_vertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]],
        const device GridUniforms* gridUniforms [[ buffer(2) ]],
        const device Light* lights [[ buffer(3) ]]) {
    float4 position = float4(vertexIn.position, 0, 1);

    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * sharedUniforms->worldMatrix * position;

    float3 color = float3(0.01, 0.01, 0.01);
    for (int i = 0; i < gridUniforms->numLights; i++) {
        color = max(color, computeLightContribution(lights[i], float3(vertexIn.position, 0)));
    }
    projectedVertex.color = float4(color, 0.5);

    return projectedVertex;
}

fragment half4 grid_fragment(ProjectedVertex vert [[ stage_in ]]) {
    return half4(vert.color.r, vert.color.g, vert.color.b, vert.color.a);
}
//
//  ParticleShader.metal
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/25/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
#import "Shared.h"

using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float colorFactor [[ attribute(1) ]];
};

struct ParticleRendererUniforms {
    float currentTime;
};

struct Particle {
    float3 position;
    float3 direction;
    float3 color;
    float speed;
    float length;
    float thickness;
    float lifespan;
    float hiddenDate;
    float destructionDate;
    float4x4 rotationMatrix;
};

struct ProjectedVertex {
    float4 position [[ position ]];
    float4 color;
};

float easeOut(float p);
float easeOut(float p) {
    p = 1 - p;
    return 1 - p * p * p;
}

vertex ProjectedVertex particle_vertex(
        const VertexIn vertexIn [[ stage_in ]],
        const device SharedUniforms* sharedUniforms [[ buffer(1) ]],
        const device Particle* particles [[ buffer(2) ]],
        const device ParticleRendererUniforms* particleRendererUniforms [[ buffer(3) ]],
        unsigned int iid [[ instance_id ]]) {
    if (particles[iid].hiddenDate > 0 && particleRendererUniforms[0].currentTime > particles[iid].hiddenDate) {
        ProjectedVertex projectedVertex;
        projectedVertex.position = float4(-1000, -1000, -1000, 1);
        projectedVertex.color = float4(0, 0, 0, 0);
        return projectedVertex;
    }

    float percentageCompleted = particles[iid].hiddenDate > 0 ? (1 - (particles[iid].hiddenDate - particleRendererUniforms[0].currentTime) / particles[iid].lifespan) : 0;
    percentageCompleted = easeOut(percentageCompleted);

    float4 position = float4(vertexIn.position, 1);
    position[0] *= particles[iid].thickness;
    position[1] *= particles[iid].length * (1 - percentageCompleted);
    if (particles[iid].hiddenDate > 0) {
        // For some reason this is faster than doing matrix multiplication.
        position = particles[iid].rotationMatrix * position;
        position += float4(particles[iid].position * 2 + particles[iid].direction * particles[iid].speed * percentageCompleted * 2, 1);
    } else {
        position = float4(particles[iid].position * 2, 1) + particles[iid].rotationMatrix * position;
    }

    ProjectedVertex projectedVertex;
    projectedVertex.position = sharedUniforms->projectionMatrix * sharedUniforms->worldMatrix * position;
    projectedVertex.color = float4(particles[iid].color - (particles[iid].color * 0.5 * percentageCompleted), 0.85);

    return projectedVertex;
}

fragment half4 particle_fragment(ProjectedVertex vert [[ stage_in ]]) {
    return half4(vert.color.r, vert.color.g, vert.color.b, vert.color.a);
}
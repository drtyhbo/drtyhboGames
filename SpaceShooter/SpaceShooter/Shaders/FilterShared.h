//
//  FilterShared.h
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float2 texCoords [[ attribute(1) ]];
};

struct SharedUniforms {
    float4x4 projectionMatrix;
};
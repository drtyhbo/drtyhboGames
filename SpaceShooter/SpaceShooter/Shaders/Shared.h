//
//  Shared.h
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/25/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

#ifndef Shared_h
#define Shared_h

using namespace metal;

struct SharedUniforms {
    float4x4 projectionMatrix;
    float4x4 worldMatrix;
};

#endif /* Shared_h */

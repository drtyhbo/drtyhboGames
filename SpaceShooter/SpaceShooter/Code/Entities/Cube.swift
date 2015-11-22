//
//  Cube.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/4/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class Cube: Enemy {
    override var scale: vector_float3 {
        return [2, 2, 2]
    }

    private var velocity: float3 = float3(0, 0, 0)
    private var rotationSpeed: float3 = float3(0, 0, 0)

    init() {
        super.init(name: "cube", pointValue: 1, gemCount: 1)

        color = float4(1, 0, 0, 1)
        velocity = float3(Float(arc4random_uniform(16)) - 8, Float(arc4random_uniform(16)) - 8, 0)
        rotationSpeed = float3((Float(arc4random_uniform(32)) - 16) / 16, (Float(arc4random_uniform(32)) - 16) / 16, 0)
    }

    override func updateWithDelta(delta: Float) {
        color[3] = state == .Alive ? Float(min(1, timeSinceLastState / 2)) : Float(0)

        if isActive {
            position += velocity * delta
            let collision = World.doesCollide(self)
            if collision.contains(.Left) || collision.contains(.Right) {
                self.velocity[0] *= -1
            }
            if collision.contains(.Top) || collision.contains(.Bottom) {
                self.velocity[1] *= -1
            }
        }

        rotation += rotationSpeed * delta

        super.updateWithDelta(delta)
    }
}
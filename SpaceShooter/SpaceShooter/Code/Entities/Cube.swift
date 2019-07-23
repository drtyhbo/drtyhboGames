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

    private var velocity: float3!
    private var rotationSpeed: float3 = float3(0, 0, 0)

    init() {
        super.init(name: "cube", pointValue: 1, gemCount: 1)

        color = Constants.Cube.color
        rotationSpeed = float3((Float(arc4random_uniform(32)) - 16) / 16, (Float(arc4random_uniform(32)) - 16) / 16, 0)
    }

    override func updateWithDelta(delta: Float) {
        color[3] = state == .Alive ? Float(min(1, timeSinceLastState / 2)) : Float(0)

        if isActive {
            if velocity == nil {
                if let player = GameManager.sharedManager.player {
                    velocity = Constants.Cube.speed * normalize(player.position - position)
                } else {
                    velocity = normalize(float3(Float(arc4random_uniform(16)) - 8, Float(arc4random_uniform(16)) - 8, 0)) * Constants.Cube.speed
                }
            }

            position += velocity * delta

          let collision = World.doesCollide(entity: self)
            if collision.contains(.Left) || collision.contains(.Right) {
                velocity = float3(velocity[0] * -1, velocity[1], 0)
            }
            if collision.contains(.Top) || collision.contains(.Bottom) {
                velocity = float3(velocity[0], velocity[1] * -1, 0)
            }
        }

        rotation += rotationSpeed * delta

      super.updateWithDelta(delta: delta)
    }
}

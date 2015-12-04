//
//  Gem.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/16/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Gem: Entity {
    override var scale: vector_float3 {
        if state == .Alive {
            var ageScale: Float = 1

            let fadeOutAge = Constants.Gem.lifespan - Constants.Gem.fadeOutOver
            if age > fadeOutAge {
                ageScale = 1 - (age - fadeOutAge) / Constants.Gem.fadeOutOver
            }

            return float3(ageScale * Constants.Gem.scale)
        } else {
            return float3(0)
        }
    }

    var velocity: float3 = float3(0)

    private var rotationSpeed: float3 = float3(0)
    private var spawnTime: Float
    private var age: Float {
        return GameTimer.sharedTimer.currentTime - spawnTime
    }

    init(position: float3) {
        spawnTime = GameTimer.sharedTimer.currentTime

        super.init(name: "gem")

        self.position = position
        color = Constants.Gem.color
        rotationSpeed = Constants.Gem.rotationSpeed
    }

    override func updateWithDelta(delta: Float) {
        super.updateWithDelta(delta)

        rotation += rotationSpeed * delta
        position += velocity * delta

        if age >= 5 {
            die()
        }
    }
}
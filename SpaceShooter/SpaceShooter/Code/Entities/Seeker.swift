//
//  Seeker.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Seeker: Enemy {
    override var scale: vector_float3 {
        return [1.5, 1.5, 1.5]
    }

    private var velocity: float3 {
        if let player = GameManager.sharedManager.player {
            return Constants.Seeker.speed * normalize(player.position - position)
        }
        return float3(0)
    }

    init() {
        super.init(name: "seeker", pointValue: 1, gemCount: 2)

        color = Constants.Seeker.color
        rotation = float3(Float(M_PI) / 2, 0, 0)
    }

    override func updateWithDelta(delta: Float) {
        color[3] = state == .Alive ? Float(min(1, timeSinceLastState / 2)) : Float(0)

        if isActive {
            position += velocity * delta
            rotation += float3(Float(M_PI)) * delta
        }

        super.updateWithDelta(delta)
    }
}
//
//  GravityWell.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Flyer: Enemy {
    enum Type {
        case Vertical
        case Horizontal
    }

    override var scale: vector_float3 {
        return [1.5, 1.5, 1.5]
    }

    private let type: Type
    private var direction = float3(0, 0, 0)
    private var velocity: float3 {
        return direction * Constants.Flyer.speed
    }

    init() {
        type = arc4random() % 2 == 0 ? .Vertical : .Horizontal

        super.init(name: "flyer", pointValue: 3, gemCount: 1)

        color = Constants.Flyer.color

        let sign = pow(Float(-1), Float(arc4random() % 2 + 1))
        direction = type == .Vertical ? float3(0, sign, 0) : float3(sign, 0, 0)
        rotation = [0, 0, type == .Horizontal ? Float(M_PI) / 2 : 0]
    }

    override func updateWithDelta(delta: Float) {
        color[3] = state == .Alive ? Float(min(1, timeSinceLastState / 2)) : Float(0)

        if isActive {
            position += velocity * delta
            let collision = World.doesCollide(self)
            if collision.contains(.Left) || collision.contains(.Right) {
                direction[0] *= -1
            }
            if collision.contains(.Top) || collision.contains(.Bottom) {
                direction[1] *= -1
            }
            rotation[type == .Horizontal ? 0 : 1] += Float(M_PI) * delta
        }

        super.updateWithDelta(delta)
    }
}
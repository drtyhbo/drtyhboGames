//
//  Enemy.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Enemy: Entity {
    override var scale: vector_float3 {
        return float3(1)
    }

    override var intensity: Float {
        if state == .Alive {
            return Constants.Enemy.lightIntensity * min(1, Float(timeSinceLastState) / 2)
        } else {
            return Constants.Enemy.lightIntensity * max(0, 1 - Float(timeSinceLastState) / 1)
        }
    }

    var isActive: Bool {
        return state == .Alive && timeSinceLastState > 2
    }

    var absorbsBullets: Bool {
        return false
    }

    var gemCount = 1

    let pointValue: Int
    private(set) var health: Float = 1

    init(name: String, pointValue: Int, gemCount: Int, health: Float = 1) {
        self.pointValue = pointValue
        self.gemCount = gemCount

        super.init(name: name)

        self.health = health
    }

    override func die() {
        super.die()
        GridManager.sharedManager.grid.applyExplosiveForce(Constants.Enemy.Die.gravityForce, atPosition: position, withRadius: Constants.Enemy.Die.gravityRadius)
        ParticleManager.sharedManager.createExplosionAroundPosition(position, particleCount: Constants.Enemy.Die.particleCount, color: float3(color[0], color[1], color[2]), speed: Constants.Enemy.Die.particleSpeed)

        if health <= 0 {
            for _ in 0..<gemCount {
                let randomOffset = float3(Random.randomNumberBetween(-3, and: 3), Random.randomNumberBetween(-3, and: 3), 0)
                let gem = Gem(position: position + randomOffset)
                gem.load()
                gem.spawn()
                EntityManager.sharedManager.addEntity(gem)
            }
        }
    }

    func damage() {
        health--
        if health <= 0 {
            die()
        }
    }

    func giveHealth(health: Float) {
        self.health += health
    }
}
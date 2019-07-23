//
//  Gravity.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Gravity: Enemy {
    override var absorbsBullets: Bool {
        return true
    }

    override var scale: vector_float3 {
      return float3(repeating: max(1, Float(health) / 5))
    }

    private var force: PhysicsManager.Force?
    private var rotationSpeed: float3 = float3(0, 0, 0)

    private var lastEmissionTime = GameTimer.sharedTimer.currentTime

    init() {
        super.init(name: "gravity", pointValue: 10, gemCount: 5, health: Constants.Gravity.health)

        color = Constants.Gravity.color
        rotation = float3(Float(M_PI) / 2, 0, 0)
    }

    override func updateWithDelta(delta: Float) {
      super.updateWithDelta(delta: delta)

        if isActive && force == nil {
            force = PhysicsManager.Force(type: .Attractive, strength: Constants.Gravity.gravityForce, position: position)
          PhysicsManager.sharedManager.setForce(force: force!)
        }

        let explosiveForce = state == .Alive ? min(1, Float(timeSinceLastState) / 2) * 25 : 0
      GridManager.sharedManager.grid.applyExplosiveForce(force: explosiveForce, atPosition: position, withRadius: 10)
    }

    override func die() {
        super.die()

        PhysicsManager.sharedManager.removeForce()
      GridManager.sharedManager.grid.applyExplosiveForce(force: Constants.Gravity.Die.gravityForce, atPosition: position, withRadius: Constants.Gravity.Die.gravityRadius)

      EntityManager.sharedManager.destroyEnemiesAroundPosition(position: position, withRadius: Constants.Gravity.Die.gravityRadius)
    }

    override func damage() {
        super.damage()

        if GameTimer.sharedTimer.currentTime - lastEmissionTime > 0.25 {
          ParticleManager.sharedManager.createExplosionAroundPosition(position: position, particleCount: Constants.Gravity.Damage.particleCount, color: float3(color[0], color[1], color[2]), speed: Constants.Gravity.Damage.particleSpeed)
            lastEmissionTime = GameTimer.sharedTimer.currentTime
        }
    }

    func absorbEnemy(enemy: Enemy) {
        gemCount = min(100, gemCount + enemy.gemCount)
        enemy.gemCount = 0
        enemy.die()

        if health < Constants.Gravity.health * 2 {
          giveHealth(health: 0.5)
        }
    }
}

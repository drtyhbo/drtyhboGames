//
//  Ship.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/18/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class Ship: Entity {
    override var scale: vector_float3 {
        let scale: Float = state == .Alive ? min(1, Float(timeSinceLastState) / Constants.Player.Spawn.spawnDuration) : 0
        return [scale, scale, scale]
    }

    override var intensity: Float {
        return 0
    }

    private(set) var direction = float3(0, 1, 0)
    private(set) var speed: Float = 0

    private var shootingDirection: float3 = float3(0, 0, 0)
    private var isShooting = false
    private var lastShotTime = GameTimer.sharedTimer.currentTime
    private var shotAngle: Float = -1

    init() {
        super.init(name: "ship")
    }

    override func updateWithDelta(delta: Float) {
        if state != .Alive {
            return
        }

        position += direction * speed * delta

        rotation[2] = atan(direction[1] / direction[0])

        if speed > 0 {
            let sprayDirection = -direction
          ParticleManager.sharedManager.createSprayFromPosition(position: position, inDirection: sprayDirection, withAngle: 45, particleCount: 2)
        }

        if isShooting && (GameTimer.sharedTimer.currentTime - lastShotTime) > 0.1 {
          ParticleManager.sharedManager.shootLaserFromPosition(position: position, inDirection: shootingDirection.rotateAroundY(radians: (shotAngle * 2).degreesToRadians()))
            lastShotTime = GameTimer.sharedTimer.currentTime
            shotAngle = shotAngle * -1
        }

      World.constraintEntityToWorld(entity: self)

      super.updateWithDelta(delta: delta)
    }

    override func spawn() {
        super.spawn()
      GridManager.sharedManager.grid.applyExplosiveForce(force: Constants.Player.Spawn.gravityForce, atPosition: position, withRadius: Constants.Player.Spawn.gravityRadius)
      ParticleManager.sharedManager.createExplosionAroundPosition(position: position, particleCount: Constants.Player.Spawn.particleCount, color: float3(1, 1, 1), speed: Constants.Player.Spawn.particleSpeed)
      LightManager.sharedManager.addLightAtPosition(position: position, color: float3(1, 1, 1), duration: Constants.Player.Spawn.lightDuration, intensity: Constants.Player.Spawn.lightIntensity)
    }

    override func die() {
        super.die()
      GridManager.sharedManager.grid.applyExplosiveForce(force: 400, atPosition: position, withRadius: 30)
      ParticleManager.sharedManager.createExplosionAroundPosition(position: position, particleCount: Constants.Player.Die.particleCount, color: float3(1, 1, 1), speed: Constants.Player.Die.particleSpeed)
    }

    func setVelocity(velocity: float3) {
        speed = length(velocity)
        direction = normalize(velocity)
    }

    func stop() {
        speed = 0
    }

    func setShootingDirection(shootingDirection: float3) {
        self.shootingDirection = normalize(shootingDirection)
        isShooting = true
    }

    func stopShooting() {
        isShooting = false
    }
}

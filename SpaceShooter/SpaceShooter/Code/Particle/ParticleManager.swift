//
//  ParticleManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class ParticleManager {
    static let sharedManager = ParticleManager()
    static let maxParticles = 150000

    private(set) var particles: [Particle] = []
    private(set) var laserParticles: [Particle] = []

    func updateWithDelta(delta: Float) {
        let currentTime = GameTimer.sharedTimer.currentTime

        var removalCount = 0
        for i in 0..<particles.count {
            if currentTime < particles[i].destructionTime {
                break
            }

            removalCount += 1
        }

        if removalCount > 0 {
          particles.removeSubrange(0..<removalCount)
        }

      if laserParticles.count > 0 {
          for i in (0...laserParticles.count-1).reversed() {
            laserParticles[i].updateWithDelta(delta: delta)
            if !World.isPositionInside(position: laserParticles[i].position) {
                createExplosionAroundPosition(position: laserParticles[i].position, particleCount: Constants.Particle.LaserParticle.Explosion.particleCount, color: float3(1, 1, 1), speed: Constants.Particle.LaserParticle.Explosion.particleSpeed, minLength: Constants.Particle.LaserParticle.Explosion.minLength, maxLength: Constants.Particle.LaserParticle.Explosion.maxLength)
                LightManager.sharedManager.addLightAtPosition(position: laserParticles[i].position, color: float3(1, 1, 1), duration: 0.5, intensity: 10)
                laserParticles.remove(at: i)
              }
          }
      }
    }

    func createExplosionAroundPosition(position: float3, particleCount: Int, color: float3, speed: Float, minLength: Float = 5, maxLength: Float = 20) {
        for _ in 0..<particleCount {
          let colorMultiplier = Random.randomNumberBetween(lowerBound: -0.5, and: 0.5)
            let direction = normalize(float3(randomBetween0And1() - 0.5, randomBetween0And1() - 0.5, 0))
          createTemporaryParticleAtPosition(position: position, direction: direction, speed: speed * 0.5 + randomBetween0And1() * (speed * 0.5), length: minLength + randomBetween0And1() * (maxLength - minLength), color: color + color * colorMultiplier, lifespan: randomLifespan())
        }
    }

    func createSprayFromPosition(position: float3, inDirection direction: float3, withAngle angle: Int, particleCount: Int) {
        for _ in 0..<particleCount {
            let randomAngle = (Int(arc4random()) % angle) - (angle / 2)
          let particleDirection = direction.rotateAroundY(radians: Float(Double(randomAngle) * M_PI / 180))
          createTemporaryParticleAtPosition(position: position, direction: particleDirection, speed: randomSpeed(speed: 10), length: 1 + randomBetween0And1() * 3, color: float3(1, 1, 1), lifespan: randomLifespan())
        }
    }

    func shootLaserFromPosition(position: float3, inDirection direction: float3) {
        var particle = Particle()
      particle.activateLaserWithPosition(position: position, direction: direction, speed: Constants.Particle.LaserParticle.speed, length: Constants.Particle.LaserParticle.length, color: float3(1, 1, 1))
        laserParticles.append(particle)
    }

    private func createTemporaryParticleAtPosition(position: float3, direction: float3, speed: Float, length: Float, color: float3, lifespan: Float) {
        var particle = Particle()
      particle.activateTemporaryWithPosition(position: position, direction: direction, speed: speed, length: length, color: color, lifespan: lifespan)
        particles.append(particle)
    }

    private func randomBetween0And1() -> Float {
        return Float(arc4random() % 2000) / 2000
    }

    private func randomSpeed(speed: Float) -> Float {
        return Float(arc4random() % 100) / 100 * speed + 5
    }

    private func randomLength() -> Float {
        return Float(arc4random() % 40) / 5
    }

    private func randomLifespan() -> Float {
        return randomBetween0And1() * 1 + 0.5
    }
}

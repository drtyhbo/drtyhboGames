//
//  Particle.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/23/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

struct Particle {
    private(set) var position = float3(0, 0, 0)
    private(set) var direction = float3(0, 0, 0)
    private(set) var color = float3(0, 0, 0)
    private(set) var speed: Float = 0
    private(set) var length: Float = 0
    private(set) var thickness: Float = 1

    // Fill these out for a temporary particle.
    private(set) var lifespan: Float = 0
    private(set) var hiddenTime: Float = 0
    private(set) var destructionTime: Float = 0

    private var rotationMatrix: matrix_float4x4 = float4x4(1).cmatrix

    mutating func updateWithDelta(delta: Float) {
        let physicsForce = PhysicsManager.sharedManager.calculateForcesAtPosition(position) * delta
        position += (physicsForce + direction * speed) * delta
    }

    mutating func activateTemporaryWithPosition(position: float3, direction: float3, speed: Float, length: Float, color: float3, lifespan: Float) {
        activateWithPosition(position, direction: direction, speed: speed, length: length, thickness: Constants.Particle.TemporaryParticle.thickness, color: color)

        self.lifespan = lifespan
        hiddenTime = GameTimer.sharedTimer.currentTime + min(lifespan, Constants.Particle.TemporaryParticle.maxAge)
        destructionTime = GameTimer.sharedTimer.currentTime + Constants.Particle.TemporaryParticle.maxAge
    }

    mutating func activateLaserWithPosition(position: float3, direction: float3, speed: Float, length: Float, color: float3) {
        activateWithPosition(position, direction: direction, speed: speed, length: length, thickness: Constants.Particle.LaserParticle.thickness, color: color)
    }

    private mutating func activateWithPosition(position: float3, direction: float3, speed: Float, length: Float, thickness: Float, color: float3) {
        self.position = position
        self.direction = direction
        self.speed = speed
        self.length = length
        self.thickness = thickness
        self.color = color

        let xAxis = normalize(cross(direction, float3(0, 0, 1)))
        let yAxis = normalize(cross(direction, xAxis))
        rotationMatrix.columns = (
            float4(xAxis, 0),
            float4(direction, 0),
            float4(yAxis, 0),
            float4(0, 0, 0, 1)
        )
    }
}
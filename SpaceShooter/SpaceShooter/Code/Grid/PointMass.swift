//
//  PointMass.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/24/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

struct PointMass {
    private(set) var position: float2
    private(set) var velocity = float2(0, 0)
    private var inverseMass: Float
    private var damping: Float = 0.98
    private var acceleration = float2(0, 0)

    init(position: float2, inverseMass: Float) {
        self.position = position
        self.inverseMass = inverseMass
    }

    mutating func applyForce(force: float2) {
        acceleration += force * inverseMass
    }

    mutating func increaseDampingBy(factor: Float) {
        damping *= factor
    }

    mutating func updateWithDelta(delta: Float) {
        if inverseMass == 0 {
            return
        }

        velocity += acceleration
        position += velocity * delta
        acceleration = float2(0, 0)

        if length(velocity) < 0.001 {
            velocity = float2(0, 0)
        }

        velocity -= velocity * (damping * delta)
    }
}
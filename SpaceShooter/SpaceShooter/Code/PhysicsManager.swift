//
//  PhysicsManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class PhysicsManager {
    class Force {
        enum Type {
            case Attractive
            case Repulsive
        }

        let type: Type
        var strength: Float
        let position: float3

        init(type: Type, strength: Float, position: float3) {
            self.type = type
            self.strength = strength
            self.position = position
        }
    }

    static let sharedManager = PhysicsManager()

    private var force: Force?
    private var hasForces: Bool {
        return force != nil
    }

    func setForce(force: Force) {
        self.force = force
    }

    func removeForce() {
        force = nil
    }

    func calculateForcesAtPosition(position: float3) -> float3 {
        var forceVector = float3(0, 0, 0)

        if let force = force {
            let gravityVector = force.position - position
            let gravityStrength = force.strength / length_squared(gravityVector)
            forceVector += gravityVector * gravityStrength
        }

        return forceVector
    }
}
//
//  Grid.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/24/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class GridManager {
    static let sharedManager = GridManager()

    let grid: Grid

    private let gridSpacing: Float = 2.5

    init() {
        grid = Grid(x: World.extents.x, y: World.extents.y, width: World.extents.width, height: World.extents.height, spacing: gridSpacing)
    }
}

class Grid {
    private struct Spring {
        let mass1: Int
        let mass2: Int
    }

    private(set) var pointMasses:[PointMass] = []
    private(set) var indices: [UInt16] = []

    private var springs: [Spring] = []
    private var spacing: Float

    init(x: Float, y: Float, width: Float, height: Float, spacing: Float) {
        self.spacing = spacing

        let numberOfColumns = Int(width / spacing) + 1
        let numberOfRows = Int(height / spacing) + 1

        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                let position = float3(x + Float(column) * spacing, y + Float(row) * spacing, 0)
                let inverseMass: Float
                if column == 0 || row == 0 || column == numberOfColumns - 1 || row == numberOfRows - 1 {
                    inverseMass = 0
                } else if column % 5 == 0 || row % 5 == 0 {
                    inverseMass = 0.5
                } else {
                    inverseMass = 1
                }
                pointMasses.append(PointMass(position: position, inverseMass: inverseMass))
            }
        }

        for row in 0..<numberOfRows {
            for column in 0..<numberOfColumns {
                if column < numberOfColumns - 1 {
                    addSpring(row * numberOfColumns + column, mass2: row * numberOfColumns + column + 1)
                }
                if row < numberOfRows - 1 {
                    addSpring(row * numberOfColumns + column, mass2: (row + 1) * numberOfColumns + column)
                }
            }
        }
    }

    private func addSpring(mass1: Int, mass2: Int) {
        springs.append(Spring(mass1: mass1, mass2: mass2))
        indices = indices + [UInt16(mass1), UInt16(mass2)]
    }

    func updateWithDelta(delta: Float) {
        for spring in springs {
            let mass1 = pointMasses[spring.mass1]
            let mass2 = pointMasses[spring.mass2]

            let positionDelta = mass1.position - mass2.position
            let currentLength = length(positionDelta)
            if currentLength <= spacing {
                continue
            }

            let velocityDelta = mass2.velocity - mass1.velocity
            let force = 4 * normalize(positionDelta) * (currentLength - spacing) - velocityDelta * 0.05

            pointMasses[spring.mass1].applyForce(-force)
            pointMasses[spring.mass2].applyForce(force)
        }

        for i in 0..<pointMasses.count {
            pointMasses[i].updateWithDelta(delta)
        }
    }

    func applyExplosiveForce(force: Float, atPosition position: float3, withRadius radius: Float) {
        for i in 0..<pointMasses.count {
            let pointMass = pointMasses[i]
            let direction = pointMass.position - position
            let distanceSquared = length_squared(direction)
            if distanceSquared < radius * radius {
                pointMasses[i].applyForce(100 * force * direction * (1 / (10000 + distanceSquared)))
                pointMasses[i].increaseDampingBy(0.6)
            }
        }
    }
}
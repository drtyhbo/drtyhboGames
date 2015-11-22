//
//  World.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class World {
    struct CollisionTypes: OptionSetType {
        let rawValue: UInt
        static let None = CollisionTypes(rawValue: 0)
        static let Left = CollisionTypes(rawValue: 1 << 0)
        static let Top = CollisionTypes(rawValue: 1 << 1)
        static let Right = CollisionTypes(rawValue: 1 << 2)
        static let Bottom = CollisionTypes(rawValue: 1 << 3)
    }

    struct Extents {
        let x: Float
        let y: Float
        let width: Float
        let height: Float
    }
    static let extents = Extents(x: -45, y: -35, width: 90, height: 70)

    static func positionEntityInWorld(entity: Entity) {
        entity.position = float3(
            Float(arc4random() % UInt32(extents.width - Constants.World.spawnPadding * 2)) + extents.x + Constants.World.spawnPadding,
            Float(arc4random() % UInt32(extents.height - Constants.World.spawnPadding * 2)) + extents.y + Constants.World.spawnPadding,
            0)
    }

    static func constraintEntityToWorld(entity: Entity) {
        entity.position[0] = max(extents.x, min(extents.x + extents.width, entity.position[0]))
        entity.position[1] = max(extents.y, min(extents.y + extents.height, entity.position[1]))
    }

    static func doesCollide(entity: Entity) -> CollisionTypes {
        var collision: CollisionTypes = []
        if entity.position[0] < extents.x  {
            collision.insert(.Left)
        }
        if entity.position[0] > extents.x + extents.width {
            collision.insert(.Right)
        }
        if entity.position[1] < extents.y {
            collision.insert(.Top)
        }
        if entity.position[1] > extents.y + extents.height {
            collision.insert(.Bottom)
        }
        return collision
    }

    static func isPositionInside(position: float3) -> Bool {
        return position.x >= extents.x && position.x <= extents.x + extents.width && position.y >= extents.y && position.y <= extents.y + extents.height
    }
}
//
//  EntityManager.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/6/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class EntityManager {
    static let sharedManager = EntityManager()

    static let maxEntities = 1000

    var entities: [Entity] {
        var entities: [Entity] = []
        for (_, entitiesOfType) in entitiesByName {
            entities += entitiesOfType
        }
        return entities
    }

    var numberOfEnemies: Int {
        var numberOfEnemies = 0
        for (_, entitiesOfType) in entitiesByName {
            if entitiesOfType.count > 0 && entitiesOfType[0] is Enemy {
                numberOfEnemies += entitiesOfType.count
            }
        }
        return numberOfEnemies
    }

    private var entitiesByName: [String:[Entity]] = [:]

    func addEntity(entity: Entity) {
        if entitiesByName[entity.name] == nil {
            entitiesByName[entity.name] = []
        }
        entitiesByName[entity.name]?.append(entity)
    }

    func updateWithDelta(delta: Float, worldMatrix: Matrix4) {
        for (name, var entities) in entitiesByName {
            for var i = entities.count - 1; i >= 0; i-- {
                let entity = entities[i]

                if !(entity is Gem) && !(entity is Gravity) && entity.state == .Alive {
                    entity.position += PhysicsManager.sharedManager.calculateForcesAtPosition(entity.position) * delta
                }

                entity.updateWithDelta(delta)
                if entity.state == .Dead {
                    entities.removeAtIndex(i)
                }
            }
            entitiesByName[name] = entities
        }
    }

    func hasEntityWithName(name: String) -> Bool {
        return entitiesByName[name]?.count > 0
    }

    func destroyEnemiesAroundPosition(position: float3, withRadius radius: Float) {
        let radiusSquared = radius * radius

        let entities = self.entities
        for entity in entities {
            if entity is Enemy && entity.state == .Alive {
                if length_squared(entity.position - position) < radiusSquared {
                    entity.die()
                }
            }
        }
    }
}
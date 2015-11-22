//
//  CollisionManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/16/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class CollisionManager {
    func testCollisionsWithPlayer(player: Ship?, gameState: GameState) {
        if let gravity = gravityFromEntities(EntityManager.sharedManager.entities) {
            for entity in EntityManager.sharedManager.entities {
                if let enemy = entity as? Enemy where entity !== gravity && length_squared(enemy.position - gravity.position) < 4 {
                    gravity.absorbEnemy(enemy)
                }
            }
        }

        if let player = player where player.state == .Alive {
            for entity in EntityManager.sharedManager.entities {
                if let enemy = entity as? Enemy where enemy.isActive && length_squared(entity.position - player.position) < 4 {
                    player.die()
                    for entity in EntityManager.sharedManager.entities {
                        entity.die()
                    }
                    gameState.state = .MainPlayerDestroyed
                    break
                }

                if let gem = entity as? Gem where gem.state == .Alive {
                    let directionToPlayer = player.position - gem.position
                    let lengthBetweenGemAndPlayer = length_squared(gem.position - player.position)
                    if lengthBetweenGemAndPlayer < 2 {
                        gem.die()
                        gameState.incrementMultiplierBy(1)
                    } else {
                        gem.velocity = lengthBetweenGemAndPlayer < 36 ? normalize(directionToPlayer) * 50 : float3(0, 0, 0)
                    }
                }
            }
        }
    }

    private func gravityFromEntities(entities: [Entity]) -> Gravity? {
        for entity in entities {
            if entity is Gravity {
                return (entity as! Gravity)
            }
        }
        return nil
    }
}
//
//  EntitySpawner.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class EntitySpawner {
    private var entitiesToSpawn: Int = 0
    private var totalEntitiesSpawned: Int = 0
    private var lastSpawnTime = GameTimer.sharedTimer.currentTime
    private var spawnReadyTime: Float?

    private let spawnSize: Int = 100
    private var difficulty: Float = 5

    func maybeSpawn() {
        let timeSinceLastSpawn = GameTimer.sharedTimer.currentTime - lastSpawnTime

        let numberOfEnemies = EntityManager.sharedManager.numberOfEnemies
        if totalEntitiesSpawned >= entitiesToSpawn && numberOfEnemies <= totalEntitiesSpawned / 2 && spawnReadyTime == nil {
            spawnReadyTime = GameTimer.sharedTimer.currentTime
        }

        if numberOfEnemies == 0 || spawnReadyTime != nil && GameTimer.sharedTimer.currentTime - spawnReadyTime! > Constants.Enemy.Spawn.timeToSpawn {
            spawnReadyTime = nil
            entitiesToSpawn = Int(difficulty)
            totalEntitiesSpawned = 0
            difficulty *= 1.3
        }

        if entitiesToSpawn > totalEntitiesSpawned && timeSinceLastSpawn > 1 {
            lastSpawnTime = GameTimer.sharedTimer.currentTime

            let spawnSize = min(self.spawnSize, entitiesToSpawn - totalEntitiesSpawned)
            for _ in 0..<spawnSize {
                let random = arc4random() % 10

                let entity: Entity
                if random < 2 {
                    entity = Flyer()
                } else if random < 6 {
                    entity = Seeker()
                } else {
                    entity = Cube()
                }
                entity.load()
                entity.spawn()
              World.positionEntityInWorld(entity: entity)
              EntityManager.sharedManager.addEntity(entity: entity)
            }
            totalEntitiesSpawned += spawnSize
        }
    }

    func makeEasier() {
        difficulty = max(5, difficulty / 4)

        entitiesToSpawn = 0
        totalEntitiesSpawned = 0
    }

    func reset() {
        difficulty = 5

        entitiesToSpawn = 0
        totalEntitiesSpawned = 0
    }
}

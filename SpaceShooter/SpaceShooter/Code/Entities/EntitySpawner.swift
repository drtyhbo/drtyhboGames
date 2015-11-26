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

    private let spawnSize: Int = 30
    private var difficulty: Float = 30

    func maybeSpawn() {
        let timeSinceLastSpawn = GameTimer.sharedTimer.currentTime - lastSpawnTime
        let shouldSpawn = timeSinceLastSpawn > 10 || EntityManager.sharedManager.numberOfEnemies <  totalEntitiesSpawned / 4
        if entitiesToSpawn == 0 || entitiesToSpawn == totalEntitiesSpawned && shouldSpawn {
            spawn()
            difficulty *= 1.5
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
                World.positionEntityInWorld(entity)
                EntityManager.sharedManager.addEntity(entity)
            }
            totalEntitiesSpawned += spawnSize
        }
    }

    func makeEasier() {
        difficulty = max(20, difficulty / 4)

        entitiesToSpawn = 0
        totalEntitiesSpawned = 0
    }

    func reset() {
        difficulty = 30
    }

    private func spawn() {
        entitiesToSpawn = Int(difficulty)
        totalEntitiesSpawned = 0
    }
}
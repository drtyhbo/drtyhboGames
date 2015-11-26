//
//  GameManager.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/16/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class GameManager {
    static let sharedManager = GameManager()

    let camera = Camera()
    let gameState: GameState
    var player: Ship?

    var isPaused: Bool = false {
        didSet {
            if isPaused == oldValue {
                return
            }

            GameTimer.sharedTimer.pause(isPaused)
        }
    }
    private var timeSincePaused = NSDate()

    private var labels: Labels = Labels()
    private var renderManager: RenderManager!
    private var collisionManager: CollisionManager = CollisionManager()
    private var sharedUniformsBufferQueue: BufferQueue!
    private var lastFrameTimestamp: CFTimeInterval!

    init() {
        gameState = GameState()
        gameState.delegate = self
    }

    func setupWithDevice(device: MTLDevice, renderManager: RenderManager) {
        self.renderManager = renderManager
        sharedUniformsBufferQueue = BufferQueue(device: device, length: SharedUniforms.size)
    }

    func nextFrameWithTimestamp(timestamp: CFTimeInterval) {
        if lastFrameTimestamp == nil {
            lastFrameTimestamp = timestamp
        }

        let delta = Float(timestamp - lastFrameTimestamp)
        lastFrameTimestamp = timestamp

        renderManager.beginFrame()
        gameUpdate(isPaused ? 0 : delta)
        renderManager.endFrame()
    }

    private var lastUpdate: NSTimeInterval = 0

    private func gameUpdate(delta: Float) {
        autoreleasepool {
            gameState.updateWithDelta(delta)

            collisionManager.testCollisionsWithPlayer(player, gameState: gameState)

            let sharedUniforms = camera.sharedUniforms()

            for entity in EntityManager.sharedManager.entities {
                if let enemy = entity as? Enemy where enemy.isDead {
                    if enemy.health <= 0 {
                        gameState.incrementScoreBy(enemy.pointValue)

                        for _ in 0..<enemy.gemCount {
                            let randomOffset = float3(Random.randomNumberBetween(-3, and: 3), Random.randomNumberBetween(-3, and: 3), 0)
                            let gem = Gem(position: enemy.position + randomOffset)
                            gem.load()
                            gem.spawn()
                            EntityManager.sharedManager.addEntity(gem)
                        }
                    }
                }
            }

            EntityManager.sharedManager.updateWithDelta(Float(delta), sharedUniforms: sharedUniforms)
            ParticleManager.sharedManager.updateWithDelta(delta)
            GridManager.sharedManager.grid.updateWithDelta(delta)

            if let player = player {
                camera.pointToEntity(player)
                camera.constrainToWorld()
            }

            labels.updateWithGameState(gameState)

            renderWithSharedUniforms(sharedUniforms)
        }
    }

    private func renderWithSharedUniforms(sharedUniforms: SharedUniforms) {
        let sharedUniformsBuffer = sharedUniformsBufferQueue.nextBuffer
        sharedUniformsBuffer.copyData(sharedUniforms.projectionMatrix.raw(), size: Matrix4.size())
        sharedUniformsBuffer.copyData(sharedUniforms.worldMatrix.raw(), size: Matrix4.size())
        sharedUniformsBuffer.copyData(sharedUniforms.projectionWorldMatrix.raw(), size: Matrix4.size())

        var lights: [Light] = []

        let entities = EntityManager.sharedManager.entities
        for i in 0..<min(entities.count, 300) {
            let entity = entities[i]
            lights.append(Light(position: entity.position, color: float3(entity.color[0], entity.color[1], entity.color[2]), intensity: entity.intensity))
        }
        for particle in ParticleManager.sharedManager.laserParticles {
            lights.append(Light(position: particle.position, color: float3(1, 1, 1), intensity: 5))
        }

        renderManager.renderWithLights(lights, sharedUniformsBuffer: sharedUniformsBuffer)
    }
}

extension GameManager: GameStateDelegate {
    func gameStateRespawnPlayer(gameState: GameState) {
        if player?.state != .Alive {
            player = Ship()
            player!.load()
            player!.spawn()
            EntityManager.sharedManager.addEntity(player!)
        }
    }

    func gameStateGameOver(gameState: GameState) {
        for entity in EntityManager.sharedManager.entities {
            if !(entity is Ship) {
                entity.die()
            }
        }
    }
}
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

//            labels.pausedLabel.alpha = isPaused ? 1 : 0
            GameTimer.sharedTimer.pause(isPaused)
        }
    }
    private var timeSincePaused = NSDate()

    private var labels: Labels = Labels()
    private var renderManager: RenderManager!
    private var collisionManager: CollisionManager = CollisionManager()
    private var lastFrameTimestamp: CFTimeInterval!

    init() {
        gameState = GameState()
        gameState.delegate = self
    }

    func setupWithDevice(device: MTLDevice, renderManager: RenderManager) {
        self.renderManager = renderManager
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

    private func gameUpdate(delta: Float) {
        autoreleasepool {
            gameState.updateWithDelta(delta)
            if gameState.state != .Intro {
                updateGameWithDelta(delta)
            }

            labels.updateWithGameState(gameState)
            render()
        }
    }

    private func updateGameWithDelta(delta: Float) {
        gameState.updateWithDelta(delta)

        collisionManager.testCollisionsWithPlayer(player, gameState: gameState)

        LightManager.sharedManager.updateWithDelta(delta)
        EntityManager.sharedManager.updateWithDelta(delta)
        ParticleManager.sharedManager.updateWithDelta(delta)
        GridManager.sharedManager.grid.updateWithDelta(delta)

        if let player = player {
            camera.pointToEntity(player)
            camera.constrainToWorld()

            if gameState.state == .FinalScore && player.isAlive {
                player.die()
            }
        }
    }

    private func render() {
        let scene = Scene(camera: camera)
        scene.calculateLightsFromEntities(EntityManager.sharedManager.entities, laserParticles: ParticleManager.sharedManager.laserParticles)
        renderManager.renderScene(scene)
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
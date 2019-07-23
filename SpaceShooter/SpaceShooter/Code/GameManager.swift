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

            labels.pausedLabel.alpha = isPaused ? 1 : 0
          GameTimer.sharedTimer.pause(shouldPause: isPaused)
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
      gameUpdate(delta: isPaused ? 0 : delta)
        renderManager.endFrame()
    }

    private func gameUpdate(delta: Float) {
        autoreleasepool {
          gameState.updateWithDelta(delta: delta)
            if gameState.state != .Intro {
              updateGameWithDelta(delta: delta)
            }

          labels.updateWithGameState(gameState: gameState)
            render()
        }
    }

    private func updateGameWithDelta(delta: Float) {
      gameState.updateWithDelta(delta: delta)

      collisionManager.testCollisionsWithPlayer(player: player, gameState: gameState)

      LightManager.sharedManager.updateWithDelta(delta: delta)
      EntityManager.sharedManager.updateWithDelta(delta: delta)
      ParticleManager.sharedManager.updateWithDelta(delta: delta)
      GridManager.sharedManager.grid.updateWithDelta(delta: delta)

        if let player = player {
          camera.pointToEntity(entity: player)

            if gameState.state == .FinalScore && player.isAlive {
                player.die()
            }
        }
    }

    private func render() {
        let scene = Scene(camera: camera)
      scene.calculateLightsFromEntities(entities: EntityManager.sharedManager.entities, laserParticles: ParticleManager.sharedManager.laserParticles)
      renderManager.renderScene(scene: scene)
    }
}

extension GameManager: GameStateDelegate {
    func gameStateRespawnPlayer(gameState: GameState) {
        if player?.state != .Alive {
            player = Ship()
            player!.load()
            player!.spawn()
          EntityManager.sharedManager.addEntity(entity: player!)
        }
    }
}

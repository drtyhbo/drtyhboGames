//
//  GameState.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

protocol GameStateDelegate: class {
    func gameStateRespawnPlayer(gameState: GameState)
    func gameStateGameOver(gameState: GameState)
}

class GameState {
    enum State {
        case GameStart
        case MainPlayerSpawing
        case Playing
        case MainPlayerDestroyed
        case GameOver
    }

    weak var delegate: GameStateDelegate?

    var state: State = .GameStart {
        didSet {
            if state == oldValue {
                return
            }

            timeOfStateChange = GameTimer.sharedTimer.currentTime

            if state == .MainPlayerDestroyed {
                entitySpawner.makeEasier()
                multiplier = 1
            } else if state == .GameOver {
                entitySpawner.reset()
            }
        }
    }

    var gameTimeRemaining: Float {
        return max(0, Constants.Game.duration - (GameTimer.sharedTimer.currentTime - gameStartTime))
    }

    var maxScore: Int {
        return max(score, previousMaxScore)
    }
    private(set) var score = 0
    private(set) var multiplier = 1

    private var previousMaxScore = 0
    private var entitySpawner: EntitySpawner = EntitySpawner()
    private var gameStartTime = GameTimer.sharedTimer.currentTime
    private var timeOfStateChange = GameTimer.sharedTimer.currentTime
    private var timeSinceLastStateChange: Float {
        return GameTimer.sharedTimer.currentTime - timeOfStateChange
    }

    init() {
        previousMaxScore = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaults.maxScoreKey) as? Int ?? 0
    }

    func updateWithDelta(delta: Float) {
        switch (state) {
            case .GameStart:
                gameStartTime = GameTimer.sharedTimer.currentTime
                delegate?.gameStateRespawnPlayer(self)
                state = .MainPlayerSpawing

            case .MainPlayerSpawing:
                if timeSinceLastStateChange > 1 {
                    state = .Playing
                }

            case .Playing:
                entitySpawner.maybeSpawn()

            case .MainPlayerDestroyed:
                if timeSinceLastStateChange > 2 {
                    delegate?.gameStateRespawnPlayer(self)
                    state = .MainPlayerSpawing
                }

            case .GameOver:
                if timeSinceLastStateChange > 1 {
                    score = 0
                    multiplier = 1

                    gameStartTime = GameTimer.sharedTimer.currentTime
                    state = .GameStart
                }
        }

        if gameTimeRemaining <= 0 && state != .GameOver {
            previousMaxScore = maxScore
            NSUserDefaults.standardUserDefaults().setInteger(previousMaxScore, forKey: Constants.UserDefaults.maxScoreKey)

            state = .GameOver
            delegate?.gameStateGameOver(self)
        }
    }

    func incrementScoreBy(points: Int) {
        score += points * multiplier
    }

    func incrementMultiplierBy(multiplier: Int) {
        self.multiplier += multiplier
    }
}
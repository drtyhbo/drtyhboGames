//
//  GameState.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import GameKit

protocol GameStateDelegate: class {
    func gameStateRespawnPlayer(gameState: GameState)
}

class GameState {
    enum State {
        case Intro
        case GameStart
        case MainPlayerSpawing
        case Playing
        case MainPlayerDestroyed
        case GameOver
        case FinalScore
    }

    weak var delegate: GameStateDelegate?

    var state: State = .Intro {
        didSet {
            if state == oldValue {
                return
            }

            timeOfStateChange = GameTimer.sharedTimer.currentTime

            if state == .MainPlayerDestroyed {
                allTimeHighScore = max(score, allTimeHighScore)

                if score == allTimeHighScore {
                    let gkScore = GKScore(leaderboardIdentifier: "com.drtyhbo.SpaceShooter.HighScore")
                    gkScore.value = Int64(score)
                    GKScore.reportScores([gkScore], withCompletionHandler: nil)
                }

                NSUserDefaults.standardUserDefaults().setInteger(allTimeHighScore, forKey: Constants.UserDefaults.maxScoreKey)
            } else if state == .GameOver {
                entitySpawner.reset()
            }
        }
    }

    var gameTimeElapsed: Float {
        return GameTimer.sharedTimer.currentTime - gameStartTime
    }

    var timeSinceLastStateChange: Float {
        return GameTimer.sharedTimer.currentTime - timeOfStateChange
    }

    private(set) var score = 0
    private(set) var multiplier = 1

    private(set) var sessionHighScore = 0
    private(set) var allTimeHighScore = 0
    
    private var entitySpawner: EntitySpawner = EntitySpawner()
    private var gameStartTime = GameTimer.sharedTimer.currentTime
    private var timeOfStateChange = GameTimer.sharedTimer.currentTime

    init() {
        allTimeHighScore = NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaults.maxScoreKey) as? Int ?? 0
    }

    func updateWithDelta(delta: Float) {
        switch (state) {
            case .Intro:
                if timeSinceLastStateChange > 3 {
                    state = .GameStart
                }

            case .GameStart:
                gameStartTime = GameTimer.sharedTimer.currentTime
                delegate?.gameStateRespawnPlayer(self)
                state = .MainPlayerSpawing

            case .MainPlayerSpawing:
                if timeSinceLastStateChange > 2 {
                    state = .Playing
                }

            case .Playing:
                entitySpawner.maybeSpawn()

            case .MainPlayerDestroyed:
                state = .GameOver

            case .GameOver:
                if timeSinceLastStateChange > 2 {
                    state = .FinalScore
                }

            case .FinalScore:
                if timeSinceLastStateChange > 5 {
                    score = 0
                    multiplier = 1

                    gameStartTime = GameTimer.sharedTimer.currentTime
                    state = .Intro
                }
        }
    }

    func incrementScoreBy(points: Int) {
        score += points * multiplier
    }

    func incrementMultiplierBy(multiplier: Int) {
        self.multiplier += multiplier
    }
}
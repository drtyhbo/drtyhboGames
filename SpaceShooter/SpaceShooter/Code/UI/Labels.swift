//
//  Labels.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/14/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Labels {
    let timeRemainingLabel: Label
    let scoreLabel: Label
    let multiplierLabel: Label
    let sessionHighScoreLabel: Label
    let allTimeHighScoreLabel: Label

    let pausedLabel: Label

    let threeMinutesLabel: Label
    let getAHighScoreLabel: Label

    let yourScoreLabel: Label
    let finalScoreLabel: Label

    init() {
        let size = Size(size: UIScreen.mainScreen().bounds.size)
        timeRemainingLabel = TextManager.sharedManager.createLabelAtPosition(float2(10, 10))
        scoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, 10), alignment: [.Right])

        multiplierLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, 30), alignment: [.Right])
        multiplierLabel.color = float3(Constants.Gem.color)

        sessionHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, Float(size.height) - 50), alignment: [.Right])
        allTimeHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, Float(size.height) - 30), alignment: [.Right])

        pausedLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, 10), alignment: [.Center])
        pausedLabel.text = "Paused"
        pausedLabel.fontSize = 48
        pausedLabel.alpha = 0

        threeMinutesLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 - 15), alignment: [.Center, .Middle])
        threeMinutesLabel.text = "You have 3 minutes"
        threeMinutesLabel.fontSize = 40

        getAHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 + 15), alignment: [.Center, .Middle])
        getAHighScoreLabel.text = "Get a high score"
        getAHighScoreLabel.fontSize = 40

        yourScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 - 15), alignment: [.Center, .Middle])
        yourScoreLabel.text = "Your score"
        yourScoreLabel.fontSize = 40
        yourScoreLabel.alpha = 0

        finalScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 + 15), alignment: [.Center, .Middle])
        finalScoreLabel.text = "0"
        finalScoreLabel.fontSize = 40
        finalScoreLabel.alpha = 0
    }

    func updateWithGameState(gameState: GameState) {
        switch (gameState.state) {
            case .Intro:
                setIntroLabelsAlpha(1)
                setFinalScoreLabelsAlpha(0)

            case .FinalScore:
                setGameLabelsAlpha(0)
                setFinalScoreLabelsAlpha(min(1, (5 - gameState.timeSinceLastStateChange) / 0.5))

                let isHighScore = gameState.score >= gameState.sessionHighScore
                if gameState.score >= gameState.allTimeHighScore {
                    yourScoreLabel.text = "New All-Time High Score!"
                } else if gameState.score >= gameState.sessionHighScore {
                    yourScoreLabel.text = "New High Score!"
                } else {
                    yourScoreLabel.text = "Your Score:"
                }
                yourScoreLabel.color = isHighScore ? Constants.UI.newHighScoreLabelColor : float3(1, 1, 1)
                finalScoreLabel.text = formatNumber(gameState.score)

            default:
                let alpha = min(1, gameState.state == .Intro ? 0 : gameState.gameTimeElapsed / 0.5)
                setGameLabelsAlpha(alpha)
                setIntroLabelsAlpha(0)
                setFinalScoreLabelsAlpha(0)

                timeRemainingLabel.text = formatTime(gameState.gameTimeRemaining)
                scoreLabel.text = formatNumber(gameState.score)
                multiplierLabel.text = "x \(formatNumber(gameState.multiplier))"
                sessionHighScoreLabel.text = formatNumber(gameState.sessionHighScore)
                allTimeHighScoreLabel.text = formatNumber(gameState.allTimeHighScore)
        }
    }

    private func setGameLabelsAlpha(alpha: Float) {
        timeRemainingLabel.alpha = alpha
        scoreLabel.alpha = alpha
        multiplierLabel.alpha = alpha
        sessionHighScoreLabel.alpha = alpha
        allTimeHighScoreLabel.alpha = alpha
    }

    private func setIntroLabelsAlpha(alpha: Float) {
        threeMinutesLabel.alpha = alpha
        getAHighScoreLabel.alpha = alpha
    }

    private func setFinalScoreLabelsAlpha(alpha: Float) {
        yourScoreLabel.alpha = alpha
        finalScoreLabel.alpha = alpha
    }

    private func formatTime(time: Float) -> String {
        let intTime = Int(time)
        let minutesRemaining = intTime / 60
        let secondsRemaining = intTime - minutesRemaining * 60
        return String(format: "%01d:%02d", minutesRemaining, secondsRemaining)
    }

    private func formatNumber(number: Int) -> String {
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        return numberFormatter.stringFromNumber(number)!
    }
}
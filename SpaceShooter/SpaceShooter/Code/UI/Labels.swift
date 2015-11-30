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
    let maxScoreLabel: Label
    let pausedLabel: Label
    let threeMinutesLabel: Label
    let getAHighScoreLabel: Label

    init() {
        let size = Size(size: UIScreen.mainScreen().bounds.size)
        timeRemainingLabel = TextManager.sharedManager.createLabelAtPosition(float2(10, 10))
        scoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, 10), alignment: [.Right])

        multiplierLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, 30), alignment: [.Right])
        multiplierLabel.color = float3(Constants.Gem.color)

        maxScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width - 20, Float(size.height) - 30), alignment: [.Right])

        pausedLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, 10), alignment: [.Center])
        pausedLabel.text = "Paused"
        pausedLabel.fontSize = 48
        pausedLabel.alpha = 0

        threeMinutesLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 - 15), alignment: [.Center, .Middle])
        threeMinutesLabel.text = "3 minutes"
        threeMinutesLabel.fontSize = 40

        getAHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(size.width / 2, size.height / 2 + 15), alignment: [.Center, .Middle])
        getAHighScoreLabel.text = "Get a high score"
        getAHighScoreLabel.fontSize = 40
    }

    func updateWithGameState(gameState: GameState) {
        if gameState.state != .Intro {
            timeRemainingLabel.text = formatTime(gameState.gameTimeRemaining)
            scoreLabel.text = formatNumber(gameState.score)
            multiplierLabel.text = "x \(formatNumber(gameState.multiplier))"
            maxScoreLabel.text = formatNumber(gameState.maxScore)
        }

        let alpha = min(1, gameState.state == .Intro ? 0 : gameState.gameTimeElapsed / 0.5)
        timeRemainingLabel.alpha = alpha
        scoreLabel.alpha = alpha
        multiplierLabel.alpha = alpha
        maxScoreLabel.alpha = alpha
        threeMinutesLabel.alpha = 1 - alpha
        getAHighScoreLabel.alpha = 1 - alpha
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
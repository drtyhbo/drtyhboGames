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

    init() {
        let size = UIScreen.mainScreen().bounds.size
        timeRemainingLabel = TextManager.sharedManager.createLabelAtPosition(float2(10, 10))
        scoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(Float(size.width) - 20, 10), alignment: .Right)
        multiplierLabel = TextManager.sharedManager.createLabelAtPosition(float2(Float(size.width) - 20, 30), alignment: .Right)
        maxScoreLabel = TextManager.sharedManager.createLabelAtPosition(float2(Float(size.width) - 20, Float(size.height) - 30), alignment: .Right)

    }

    func updateWithGameState(gameState: GameState) {
        timeRemainingLabel.text = formatTime(gameState.gameTimeRemaining)
        scoreLabel.text = formatNumber(gameState.score)
        multiplierLabel.text = "x \(formatNumber(gameState.multiplier))"
        maxScoreLabel.text = formatNumber(gameState.maxScore)
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
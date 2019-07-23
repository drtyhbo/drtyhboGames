//
//  Labels.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/14/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Labels {
    let scoreLabel: Label
    let multiplierLabel: Label

    let pausedLabel: Label

    let getAHighScoreLabel: Label
    let beatYourHighScoreLabel: Label
    let highScoreLabel: Label

    let yourScoreLabel: Label
    let finalScoreLabel: Label

    init() {
      let size = Size(size: UIScreen.main.bounds.size)

      scoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, 10), alignment: [.Center], shouldPulse: true)
        scoreLabel.fontSize = 35

      multiplierLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, 50), alignment: [.Center], shouldPulse: true)
        multiplierLabel.color = float3(Constants.Gem.color)

      pausedLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(10, 10), alignment: [.Left])
        pausedLabel.text = "Paused"
        pausedLabel.fontSize = 30
        pausedLabel.alpha = 0

      getAHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, size.height / 2), alignment: [.Center, .Middle])
        getAHighScoreLabel.text = "Get a high score"
        getAHighScoreLabel.fontSize = 35
        getAHighScoreLabel.color = Constants.UI.highScoreLabelColor
        getAHighScoreLabel.alpha = 0

      beatYourHighScoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, size.height / 2 - 20), alignment: [.Center, .Middle])
        beatYourHighScoreLabel.text = "Beat your high score:"
        beatYourHighScoreLabel.fontSize = 25
        beatYourHighScoreLabel.alpha = 0

      highScoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, size.height / 2 + 20), alignment: [.Center, .Middle])
        highScoreLabel.fontSize = 35
        highScoreLabel.color = Constants.UI.highScoreLabelColor
        highScoreLabel.alpha = 0

      yourScoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, size.height / 2 - 20), alignment: [.Center, .Middle])
        yourScoreLabel.text = "Your score"
        yourScoreLabel.fontSize = 25
        yourScoreLabel.alpha = 0

      finalScoreLabel = TextManager.sharedManager.createLabelAtPosition(position: float2(size.width / 2, size.height / 2 + 20), alignment: [.Center, .Middle])
        finalScoreLabel.text = "0"
        finalScoreLabel.fontSize = 35
        finalScoreLabel.alpha = 0
    }

    func updateWithGameState(gameState: GameState) {
        switch (gameState.state) {
            case .Intro:
              setIntroLabelsAlpha(alpha: 1, score: gameState.allTimeHighScore)
                setFinalScoreLabelsAlpha(alpha: 0)

            case .FinalScore:
              setGameLabelsAlpha(alpha: 0)
              setFinalScoreLabelsAlpha(alpha: min(1, (5 - gameState.timeSinceLastStateChange) / 0.5))

                if gameState.score >= gameState.allTimeHighScore {
                    yourScoreLabel.text = "New High Score:"
                    finalScoreLabel.color = Constants.UI.highScoreLabelColor
                } else {
                    yourScoreLabel.text = "Your Score:"
                    finalScoreLabel.color = float3(1, 1, 1)
                }

              finalScoreLabel.text = formatNumber(number: gameState.score)

            default:
                let alpha = min(1, gameState.state == .Intro ? 0 : gameState.gameTimeElapsed / 0.5)
                setGameLabelsAlpha(alpha: alpha)
                setIntroLabelsAlpha(alpha: 0)
                setFinalScoreLabelsAlpha(alpha: 0)

                scoreLabel.text = formatNumber(number: gameState.score)
                multiplierLabel.text = "x\(formatNumber(number: gameState.multiplier))"
        }
    }

    private func setGameLabelsAlpha(alpha: Float) {
        scoreLabel.alpha = alpha
        multiplierLabel.alpha = alpha
    }

    private func setIntroLabelsAlpha(alpha: Float, score: Int = 0) {
        getAHighScoreLabel.alpha = alpha > 0 ? (score > 0 ? 0 : alpha) : 0
        beatYourHighScoreLabel.alpha = alpha > 0 ? (score > 0 ? alpha : 0) : 0
        highScoreLabel.alpha = alpha > 0 ? (score > 0 ? alpha : 0) : 0

        if score > 0 {
          highScoreLabel.text = "\(formatNumber(number: score))"
        }
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
      let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
      return numberFormatter.string(from: NSNumber(value: number))!
    }
}

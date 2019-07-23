//
//  GameTimer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/21/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class GameTimer {
    static let sharedTimer = GameTimer()

    var currentTime: Float {
      return lastStoredTime + (isPaused ? 0 : Float(NSDate().timeIntervalSince(lastUpdatedDate as Date)))
    }

    private var isPaused = false
    private var lastStoredTime: Float = 0
    private var lastUpdatedDate = NSDate()

    func pause(shouldPause: Bool) {
        if shouldPause {
          lastStoredTime += Float(NSDate().timeIntervalSince(lastUpdatedDate as Date))
            isPaused = true
        } else {
            lastUpdatedDate = NSDate()
            isPaused = false
        }
    }
}

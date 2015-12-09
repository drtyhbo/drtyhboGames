//
//  Label.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/13/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Label {
    enum Alignment {
        case Left
        case Right
        case Center
        case Top
        case Bottom
        case Middle
    }

    let position: float2
    let alignment: [Alignment]
    let shouldPulse: Bool

    var text: String = "" {
        didSet {
            if shouldPulse && text != oldValue {
                pulse()
            }
        }
    }
    var alpha: Float = 1
    var fontSize: Float = 20
    var color: float3 = float3(1, 1, 1)
    var scale: Float {
        if let startPulseTime = startPulseTime {
            let currentTime = GameTimer.sharedTimer.currentTime
            if currentTime - startPulseTime < 0.25 {
                return 1 + sin((currentTime - startPulseTime) / 0.25 * Float(M_PI)) * 0.2
            }
        }
        return 1
    }

    var startPulseTime: Float!
    var startPulseScale: Float = 1

    var textRendererData: AnyObject?

    init(position: float2, alignment: [Alignment], shouldPulse: Bool = false) {
        self.position = position
        self.alignment = alignment
        self.shouldPulse = shouldPulse
    }

    func pulse() {
        let currentTime = GameTimer.sharedTimer.currentTime
        if startPulseTime == nil || currentTime - startPulseTime! > 0.25 {
            self.startPulseTime = currentTime
        }
    }
}
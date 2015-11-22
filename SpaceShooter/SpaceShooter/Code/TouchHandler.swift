//
//  TouchHandler.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/18/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

protocol TouchHandlerDelegate: class {
    func touchHandler(touchHandler: TouchHandler, center: float2, direction: float2, forTouchType touchType: TouchHandler.TouchType)
    func touchHandler(touchHandler: TouchHandler, didEndForTouchType touchType: TouchHandler.TouchType)
}

class TouchHandler {
    enum TouchType {
        case Movement
        case Shooting
    }

    class Touch {
        let touchType: TouchType
        var initialLocation: CGPoint

        init(touchType: TouchType, initialLocation: CGPoint) {
            self.touchType = touchType
            self.initialLocation = initialLocation
        }
    }

    weak var delegate: TouchHandlerDelegate?

    private let maxDistance: Float = 30

    private var touches: [UITouch:Touch] = [:]
    private var touchesByType: [TouchType:Touch] = [:]

    func touchesBegan(touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.locationInView(nil)
            let touchType = touchTypeFromLocation(location)
            if touchesByType[touchType] == nil {
                self.touches[touch] = Touch(touchType: touchType, initialLocation: location)
                touchesByType[touchType] = self.touches[touch]
            }
        }
    }

    func touchesEnded(touches: Set<UITouch>) {
        for touch in touches {
            if let touchType = self.touches[touch]?.touchType {
                touchesByType.removeValueForKey(touchType)
                self.touches.removeValueForKey(touch)
                delegate?.touchHandler(self, didEndForTouchType: touchType)
            }
        }
    }

    func touchesMoved(touches: Set<UITouch>) {
        for touch in touches {
            let location = touch.locationInView(nil)
            if let touch = self.touches[touch] {
                let direction = float2(Float(location.x - touch.initialLocation.x), Float(location.y - touch.initialLocation.y))
                var magnitude = length(direction)
                let normalizedDirection = float2(direction[0] / magnitude, direction[1] / magnitude)

                if magnitude > maxDistance {
                    magnitude = maxDistance
                    touch.initialLocation = CGPoint(x: CGFloat(Float(location.x) - normalizedDirection[0] * magnitude), y: CGFloat(Float(location.y) - normalizedDirection[1] * magnitude))
                }

                let finalDirection = normalizedDirection * magnitude
                delegate?.touchHandler(self, center: float2(Float(touch.initialLocation.x), Float(touch.initialLocation.y)), direction: float2(finalDirection[0], -finalDirection[1]), forTouchType: touch.touchType)
            }
        }
    }

    private func clampDistance(distance: Float) -> Float {
        return max(-maxDistance, min(maxDistance, distance))
    }

    private func touchTypeFromLocation(location: CGPoint) -> TouchType {
        let halfScreenWidth = UIScreen.mainScreen().bounds.width / 2
        return location.x <= halfScreenWidth ? .Movement : .Shooting
    }
}
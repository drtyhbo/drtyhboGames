//
//  TouchHandler.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/18/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

protocol TouchHandlerDelegate: class {
    func touchHandler(touchHandler: TouchHandler, didBeginTouchWithLocation location: float2, forTouchType touchType: TouchHandler.TouchType)
    func touchHandler(touchHandler: TouchHandler, didMoveWithLocation location: float2, direction: float2, forTouchType touchType: TouchHandler.TouchType)
    func touchHandler(touchHandler: TouchHandler, didEndForTouchType touchType: TouchHandler.TouchType)
}

class TouchHandler {
    enum TouchType {
        case Movement
        case Shooting
    }

    class Touch {
        let touchType: TouchType
        var initialLocation: float2

        init(touchType: TouchType, initialLocation: float2) {
            self.touchType = touchType
            self.initialLocation = initialLocation
        }
    }

    weak var delegate: TouchHandlerDelegate?

    var numTouches = 0

    private let maxDistance: Float = 30

    private var touches: [UITouch:Touch] = [:]
    private var touchesByType: [TouchType:Touch] = [:]

    func touchesBegan(touches: Set<UITouch>) {
        for touch in touches {
            let location = locationFromTouch(touch)
            let touchType = touchTypeFromLocation(location)
            if touchesByType[touchType] == nil {
                self.touches[touch] = Touch(touchType: touchType, initialLocation: location)
                touchesByType[touchType] = self.touches[touch]
                delegate?.touchHandler(self, didBeginTouchWithLocation: location, forTouchType: touchType)

                numTouches++
            }
        }
    }

    func touchesEnded(touches: Set<UITouch>) {
        for touch in touches {
            if let touchType = self.touches[touch]?.touchType {
                touchesByType.removeValueForKey(touchType)
                self.touches.removeValueForKey(touch)
                delegate?.touchHandler(self, didEndForTouchType: touchType)

                numTouches--
            }
        }
    }

    func touchesMoved(touches: Set<UITouch>) {
        for touch in touches {
            let location = locationFromTouch(touch)
            if let touch = self.touches[touch] {
                let direction = location - touch.initialLocation
                var magnitude = length(direction)
                if magnitude != 0 {
                    let normalizedDirection = direction * (1 / magnitude)

                    if magnitude > maxDistance {
                        magnitude = maxDistance
                        touch.initialLocation = location - normalizedDirection * magnitude
                    }

                    let finalDirection = normalizedDirection * magnitude
                    delegate?.touchHandler(self, didMoveWithLocation: touch.initialLocation, direction: float2(finalDirection[0], -finalDirection[1]), forTouchType: touch.touchType)
                }
            }
        }
    }

    private func locationFromTouch(touch: UITouch) -> float2 {
        let location = touch.locationInView(nil)
        return float2(Float(location.x), Float(location.y))
    }

    private func clampDistance(distance: Float) -> Float {
        return max(-maxDistance, min(maxDistance, distance))
    }

    private func touchTypeFromLocation(location: float2) -> TouchType {
        let halfScreenWidth = Float(UIScreen.mainScreen().bounds.width / 2)
        return location[0] <= halfScreenWidth ? .Movement : .Shooting
    }
}
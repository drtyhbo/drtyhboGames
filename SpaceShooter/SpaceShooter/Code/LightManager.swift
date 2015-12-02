//
//  LightManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/30/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

struct Light {
    static let size = 7 * sizeof(Float)

    let position: float3
    let color: float3
    let intensity: Float

    var floatBuffer: [Float] {
        return [position[0], position[1], position[2], color[0], color[1], color[2], intensity]
    }
}

class LightManager {
    static let sharedManager = LightManager()

    private class UpdatableLight {
        let position: float3
        let color: float3
        let startTime: Float
        let duration: Float
        let intensity: Float

        init(position: float3, color: float3, duration: Float, intensity: Float) {
            self.position = position
            self.color = color
            self.duration = duration
            self.intensity = intensity
            startTime = GameTimer.sharedTimer.currentTime
        }
    }

    private var updatableLights: [UpdatableLight] = []

    func addLightAtPosition(position: float3, color: float3, duration: Float, intensity: Float) {
        updatableLights.append(UpdatableLight(position: position, color: color, duration: duration, intensity: intensity))
    }

    func updateWithDelta(delta: Float) {
        let currentTime = GameTimer.sharedTimer.currentTime

        for var i = updatableLights.count - 1; i >= 0; i-- {
            if currentTime > updatableLights[i].startTime + updatableLights[i].duration {
                updatableLights.removeAtIndex(i)
            }
        }
    }

    func getLights() -> [Light] {
        let currentTime = GameTimer.sharedTimer.currentTime

        var lights: [Light] = []
        for updatableLight in updatableLights {
            let intensity = sin((currentTime - updatableLight.startTime) / updatableLight.duration * Float(M_PI)) * updatableLight.intensity
            lights.append(Light(position: updatableLight.position, color: updatableLight.color, intensity: intensity))
        }

        return lights
    }
}
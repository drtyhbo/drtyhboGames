//
//  Scene.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/29/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Scene {
    let camera: Camera
    private(set) var lights: [Light] = []

    // I'm not sure where else to put this.
    var cameraUniformsBuffer: Buffer?

    init(camera: Camera) {
        self.camera = camera
    }

    func calculateLightsFromEntities(entities: [Entity], laserParticles: [Particle]) {
        for i in 0..<min(entities.count, Constants.Scene.maxLights - lights.count) {
            let entity = entities[i]
            if entity.intensity > 0 {
                lights.append(Light(position: entity.position, color: float3(entity.color), intensity: entity.intensity))
            }
        }

        lights += LightManager.sharedManager.getLights()
    }
}
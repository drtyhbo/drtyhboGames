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
        for particle in ParticleManager.sharedManager.laserParticles {
            lights.append(Light(position: particle.position, color: float3(1, 1, 1), intensity: 5))
            if lights.count > Constants.Scene.maxLights {
                return
            }
        }

        for i in 0..<min(entities.count, Constants.Scene.maxLights - lights.count) {
            let entity = entities[i]
            lights.append(Light(position: entity.position, color: float3(entity.color[0], entity.color[1], entity.color[2]), intensity: entity.intensity))
        }
    }
}
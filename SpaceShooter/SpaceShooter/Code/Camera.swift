//
//  Camera.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class CameraUniforms {
    static let size = Matrix4.size() * 2

    let projectionMatrix: Matrix4
    let worldMatrix: Matrix4

    init(projectionMatrix: Matrix4, worldMatrix: Matrix4) {
        self.projectionMatrix = projectionMatrix
        self.worldMatrix = worldMatrix
    }
}

class Camera {
    var position: float3 = float3(0, 0, 100)

    var projectionMatrix: Matrix4 {
        let bounds = UIScreen.mainScreen().bounds
        return Matrix4.makePerspectiveViewAngle(viewAngle, aspectRatio: Float(bounds.size.width / bounds.size.height), nearZ: nearZ, farZ: farZ)
    }

    var worldMatrix: Matrix4 {
        let worldMatrix = Matrix4()
        worldMatrix.translate(-position[0], y: -position[1], z: -position[2])
        return worldMatrix
    }

    var cameraUniforms: CameraUniforms {
        return CameraUniforms(projectionMatrix: projectionMatrix, worldMatrix: worldMatrix)
    }

    private let viewAngle = Matrix4.degreesToRad(35)
    private let nearZ: Float = 0.01
    private let farZ: Float = 1000

    func pointToEntity(entity: Entity) {
        position[0] = entity.position[0]
        position[1] = entity.position[1]
    }
}
//
//  Camera.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Camera {
    var position: float3 = float3(0, 0, 100)
    var velocity: float3 = float3(0, 0, 0)

    var viewMatrix: Matrix4 {
        let viewMatrix = Matrix4()
        viewMatrix.translate(-position[0], y: -position[1], z: -position[2])
        return viewMatrix
    }
    private(set) var projectionMatrix: Matrix4

    private let viewAngle = Matrix4.degreesToRad(35)
    private let nearZ: Float = 0.01
    private let farZ: Float = 1000

    init() {
        let bounds = UIScreen.mainScreen().bounds
        projectionMatrix = Matrix4.makePerspectiveViewAngle(viewAngle, aspectRatio: Float(bounds.size.width / bounds.size.height), nearZ: nearZ, farZ: farZ)
    }

    func pointToEntity(entity: Entity) {
        position[0] = entity.position[0]
        position[1] = entity.position[1]
    }

    func constrainToWorld() {
        position[0] = min(15, max(-15, position[0]))
        position[1] = min(20, max(-20, position[1]))
    }

    func sharedUniforms() -> SharedUniforms {
        let projectionViewMatrix = viewMatrix.copy()
        projectionViewMatrix.multiplyLeft(projectionMatrix)
        return SharedUniforms(projectionMatrix: projectionMatrix, worldMatrix: viewMatrix, projectionWorldMatrix: projectionViewMatrix)
    }
}
//
//  Entity.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/4/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import GLKit
import Metal
import QuartzCore

class Entity {
    enum State {
        case Alive
        case Dead
    }

    let name: String
    private(set) var model: Model!

    var position: vector_float3 = [0, 0, 0]
    var rotation: vector_float3 = [0, 0, 0]
    var scale: vector_float3 {
        return [1, 1, 1]
    }
  var color: float4 = float4(repeating: 1)

    var intensity: Float {
        return 5
    }

    // MARK: State management
    var isAlive: Bool {
        return state == .Alive
    }

    var isDead: Bool {
        return state == .Dead
    }

    private(set) var state: State = .Dead {
        didSet {
            lastStateTime = GameTimer.sharedTimer.currentTime
        }
    }
    private(set) var lastStateTime = GameTimer.sharedTimer.currentTime
    var timeSinceLastState: Float {
        return GameTimer.sharedTimer.currentTime - lastStateTime
    }

    private var modelMatrix: Matrix4 {
        let matrix = Matrix4()
      matrix!.translate(position[0], y: position[1], z: position[2])
        matrix!.rotateAroundX(rotation[0], y: rotation[1], z: rotation[2])
        matrix!.scale(scale[0], y: scale[1], z: scale[2])
      return matrix!
    }

    init(name: String) {
        self.name = name
    }

    func load() -> Bool {
      if let model = ModelLoader.sharedLoader.loadWithName(name: name) {
            self.model = model
            return true
        } else {
            return false
        }
    }

    func updateWithDelta(delta: Float) {
    }

    func calculatePerInstanceMatricesWithWorldMatrix(worldMatrix: Matrix4) -> PerInstanceUniforms {
        let modelViewMatrix = modelMatrix
        modelViewMatrix.multiplyLeft(worldMatrix)

        let normalMatrix = modelViewMatrix.copy()
        normalMatrix!.invertAndTranspose()

      return PerInstanceUniforms(modelViewMatrix: modelViewMatrix, normalMatrix: normalMatrix!, color: color)
    }

    func spawn() {
        state = .Alive
    }

    func die() {
        state = .Dead
    }
}

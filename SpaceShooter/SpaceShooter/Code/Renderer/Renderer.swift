//
//  Renderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Renderer {
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!

    init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        self.device = device
        self.commandQueue = commandQueue
    }

    func customizePipelineDescriptor(pipelineDescriptor: MTLRenderPipelineDescriptor) {
    }

    func pipelineDescriptorWithVertexFunction(vertexFunction: MTLFunction, fragmentFunction: MTLFunction, vertexDescriptor: MTLVertexDescriptor, alphaBlending: Bool) -> MTLRenderPipelineDescriptor {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
      pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        if alphaBlending {
          pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
          pipelineDescriptor.colorAttachments[0].writeMask = .all
          pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
          pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
          pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
          pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
          pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
          pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
        }
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

      customizePipelineDescriptor(pipelineDescriptor: pipelineDescriptor)

        return pipelineDescriptor
    }
}

class SceneRenderer: Renderer {
    func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        fatalError("Subclasses must provide an implementation for this function.")
    }
}

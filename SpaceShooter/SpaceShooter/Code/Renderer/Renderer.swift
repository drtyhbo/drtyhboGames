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

    private(set) var drawable: CAMetalDrawable!
    private(set) var commandBuffer: MTLCommandBuffer!

    init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        self.device = device
        self.commandQueue = commandQueue
    }

    func beginFrameWithDrawable(drawable: CAMetalDrawable, commandBuffer: MTLCommandBuffer) {
        self.drawable = drawable
        self.commandBuffer = commandBuffer
    }

    func pipelineDescriptorWithVertexFunction(vertexFunction: MTLFunction, fragmentFunction: MTLFunction, vertexDescriptor: MTLVertexDescriptor, alphaBlending: Bool) -> MTLRenderPipelineDescriptor {
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        if alphaBlending {
            pipelineDescriptor.colorAttachments[0].blendingEnabled = true
            pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .SourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = .OneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .Add
            pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .SourceAlpha
            pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .OneMinusSourceAlpha
            pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .Add
        }
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        return pipelineDescriptor
    }
}
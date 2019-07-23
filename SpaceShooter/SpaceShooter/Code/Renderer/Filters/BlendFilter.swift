//
//  BlendFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class BlendFilter: FilterRenderer {
    enum BlendType {
        case Default
        case Additive
    }

    private let blendType: BlendType

    init(device: MTLDevice, commandQueue: MTLCommandQueue, blendType: BlendType) {
        self.blendType = blendType

        super.init(device: device, commandQueue: commandQueue, vertexFunction: "blendFilterVertex", fragmentFunction: "blendFilterFragment", alphaBlending: true)
    }

    override func customizeRenderPassDescriptor(renderPassDescriptor: MTLRenderPassDescriptor) {
      renderPassDescriptor.colorAttachments[0].loadAction = .load
    }

    override func customizePipelineDescriptor(pipelineDescriptor: MTLRenderPipelineDescriptor) {
      pipelineDescriptor.colorAttachments[0].isBlendingEnabled = true
      pipelineDescriptor.colorAttachments[0].writeMask = .all
      pipelineDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
      pipelineDescriptor.colorAttachments[0].destinationRGBBlendFactor = blendType == .Default ? .oneMinusSourceAlpha : .destinationAlpha
      pipelineDescriptor.colorAttachments[0].rgbBlendOperation = .add
      pipelineDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
      pipelineDescriptor.colorAttachments[0].destinationAlphaBlendFactor = blendType == .Default ? .oneMinusSourceAlpha : .destinationAlpha
      pipelineDescriptor.colorAttachments[0].alphaBlendOperation = .add
    }
}

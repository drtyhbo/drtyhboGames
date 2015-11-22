//
//  UnaryImageFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import MetalKit

class UnaryImageFilter {
    private let pipeline: MTLComputePipelineState

    init(device: MTLDevice, functionName: String) {
        let function = device.newDefaultLibrary()!.newFunctionWithName(functionName)!
        do {
            try pipeline = device.newComputePipelineStateWithFunction(function)
        } catch (let error) {
            fatalError("Unable to setup BinaryImageFilter: \(error)")
        }
    }

    func modifyCommandEncoderState(commandEncoder: MTLComputeCommandEncoder) {
    }

    func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture) {
        let threadgroupCounts = MTLSizeMake(16, 16, 1)
        let threadgroups = MTLSizeMake(sourceTexture.width / threadgroupCounts.width, sourceTexture.height / threadgroupCounts.height, 1)

        let commandEncoder = commandBuffer.computeCommandEncoder()
        commandEncoder.setComputePipelineState(pipeline)
        commandEncoder.setTexture(sourceTexture, atIndex: 0)
        commandEncoder.setTexture(destinationTexture, atIndex: 1)

        modifyCommandEncoderState(commandEncoder)

        commandEncoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCounts)
        commandEncoder.endEncoding()
    }
}
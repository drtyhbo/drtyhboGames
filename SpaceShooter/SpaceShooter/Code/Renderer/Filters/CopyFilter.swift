//
//  CopyFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class CopyFilter {
    func encodeToCommandBuffer(commandBuffer: MTLCommandBuffer, sourceTexture: MTLTexture, destinationTexture: MTLTexture) {
        let commandEncoder = commandBuffer.blitCommandEncoder()
        commandEncoder.copyFromTexture(sourceTexture, sourceSlice: 0, sourceLevel: 0, sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0), sourceSize: MTLSize(width: sourceTexture.width, height: sourceTexture.height, depth: 1), toTexture: destinationTexture, destinationSlice: 0, destinationLevel: 0, destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
        commandEncoder.endEncoding()
    }
}
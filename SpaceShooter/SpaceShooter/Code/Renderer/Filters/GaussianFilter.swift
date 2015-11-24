//
//  GaussianFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private class DirectionalBlurFilter: Filter {
    enum BlurDirection {
        case Horizontal
        case Vertical
    }

    private let direction: BlurDirection
    private let offsetsBufferQueue: BufferQueue

    init(device: MTLDevice, commandQueue: MTLCommandQueue, direction: BlurDirection) {
        self.direction = direction
        offsetsBufferQueue = BufferQueue(device: device, length: sizeof(Float) * 2)

        super.init(device: device, commandQueue: commandQueue, vertexFunction: "gaussianFilterVertex", fragmentFunction: "gaussianFilterFragment", alphaBlending: false)
    }

    override func customizeCommandEncoder(commandEncoder: MTLRenderCommandEncoder, inputTexture: MTLTexture) {
        let offsetsBuffer = offsetsBufferQueue.nextBuffer
        offsetsBuffer.copyData((direction == .Horizontal ? [1.0 / Float(inputTexture.width), 0] : [0, 1.0 / Float(inputTexture.height)]) as [Float], size: sizeof(Float) * 2)

        commandEncoder.setVertexBuffer(offsetsBuffer.buffer, offset: 0, atIndex: 2)
    }
}

class GaussianFilter {
    private let horizontalBlurFilter: DirectionalBlurFilter
    private let verticalBlurFilter: DirectionalBlurFilter

    init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        horizontalBlurFilter = DirectionalBlurFilter(device: device, commandQueue: commandQueue, direction: .Horizontal)
        verticalBlurFilter = DirectionalBlurFilter(device: device, commandQueue: commandQueue, direction: .Vertical)
    }

    func renderToCommandEncoder(commandBuffer: MTLCommandBuffer, inputTexture: MTLTexture) -> MTLTexture {
        let horizontalBlurTexture = horizontalBlurFilter.renderToCommandEncoder(commandBuffer, inputTexture: inputTexture)
        return verticalBlurFilter.renderToCommandEncoder(commandBuffer, inputTexture: horizontalBlurTexture)
    }
}
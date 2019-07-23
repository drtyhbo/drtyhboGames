//
//  GaussianFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private class DirectionalBlurFilter: FilterRenderer {
    enum BlurDirection {
        case Horizontal
        case Vertical
    }

    private let direction: BlurDirection
    private let offsetsBufferQueue: BufferQueue

    // MARK: init

    init(device: MTLDevice, commandQueue: MTLCommandQueue, direction: BlurDirection) {
        self.direction = direction
        offsetsBufferQueue = BufferQueue(device: device, length: MemoryLayout<Float>.size * 2)

        super.init(device: device, commandQueue: commandQueue, vertexFunction: "gaussianFilterVertex", fragmentFunction: "gaussianFilterFragment", alphaBlending: false)
    }

    // MARK: Overrides

    override func customizeCommandEncoder(commandEncoder: MTLRenderCommandEncoder, inputTexture: MTLTexture) {
        let offsetsBuffer = offsetsBufferQueue.nextBuffer
      offsetsBuffer.copyData(data: (direction == .Horizontal ? [1.0 / Float(inputTexture.width), 0] : [0, 1.0 / Float(inputTexture.height)]) as [Float], size: MemoryLayout<Float>.size * 2)

      commandEncoder.setVertexBuffer(offsetsBuffer.buffer, offset: 0, index: 2)
    }
}

class GaussianFilter: MultipassFilterRenderer {
    private let horizontalBlurFilter: DirectionalBlurFilter
    private let verticalBlurFilter: DirectionalBlurFilter

    // MARK: init

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        horizontalBlurFilter = DirectionalBlurFilter(device: device, commandQueue: commandQueue, direction: .Horizontal)
        verticalBlurFilter = DirectionalBlurFilter(device: device, commandQueue: commandQueue, direction: .Vertical)

        super.init(device: device, commandQueue: commandQueue)
    }

    // MARK: Overrides

    override func renderToCommandEncoder(commandBuffer: MTLCommandBuffer, inputTexture: MTLTexture) -> MTLTexture {
      let horizontalBlurTexture = horizontalBlurFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: inputTexture)
      return verticalBlurFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: horizontalBlurTexture)
    }
}

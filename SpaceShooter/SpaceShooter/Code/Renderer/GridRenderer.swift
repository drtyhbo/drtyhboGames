//
//  GridRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/24/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class GridRenderer: Renderer {
    private struct GridUniforms {
        static let size = sizeof(Int)

        let numLights: Int

        func raw() -> [Int] {
            return [numLights]
        }
    }

    private let clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)

    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var gridVertexBufferQueue: BufferQueue!
    private var gridIndexBufferQueue: BufferQueue!
    private var gridUniformsBufferQueue: BufferQueue!
    private var lightsBufferQueue: BufferQueue!

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        gridVertexBufferQueue = BufferQueue(device: device, length: sizeof(PointMass) * 1000)
        gridIndexBufferQueue = BufferQueue(device: device, length: sizeof(UInt16) * 1500)

        gridUniformsBufferQueue = BufferQueue(device: device, length: GridUniforms.size)
        lightsBufferQueue = BufferQueue(device: device, length: EntityManager.maxEntities * 3 * sizeof(Float))

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    func renderGrid(grid: Grid, sharedUniformsBuffer: Buffer, lights: [Light]) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = clearColor
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(pipelineState)

        let vertexBuffer = gridVertexBufferQueue.nextBuffer
        vertexBuffer.copyData(grid.pointMasses, size: sizeof(PointMass) * grid.pointMasses.count)

        let indexBuffer = gridIndexBufferQueue.nextBuffer
        indexBuffer.copyData(grid.indices, size: sizeof(UInt16) * grid.indices.count)

        let gridUniformsBuffer = gridUniformsBufferQueue.nextBuffer
        let gridUniforms = GridUniforms(numLights: lights.count)
        gridUniformsBuffer.copyData(gridUniforms.raw(), size: GridUniforms.size)

        let lightsBuffer = lightsBufferQueue.nextBuffer
        for light in lights {
            lightsBuffer.copyData(light.floatBuffer, size: Light.size)
        }

        commandEncoder.setVertexBuffer(vertexBuffer.buffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(sharedUniformsBuffer.buffer, offset: 0, atIndex: 1)
        commandEncoder.setVertexBuffer(gridUniformsBuffer.buffer, offset: 0, atIndex: 2)
        commandEncoder.setVertexBuffer(lightsBuffer.buffer, offset: 0, atIndex: 3)
        commandEncoder.drawIndexedPrimitives(.Line, indexCount: grid.indices.count, indexType: .UInt16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0)
        commandEncoder.endEncoding()
    }

    private func setup() {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexFunction = defaultLibrary.newFunctionWithName("grid_vertex")
        let fragmentFunction = defaultLibrary.newFunctionWithName("grid_fragment")

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.layouts[0].stride = sizeof(PointMass)
        vertexDescriptor.layouts[0].stepFunction = .PerVertex

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch let error {
            print (error)
        }

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .Less
        depthStencilDescriptor.depthWriteEnabled = true
        depthStencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
    }
}
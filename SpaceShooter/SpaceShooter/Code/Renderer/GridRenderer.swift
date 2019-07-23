//
//  GridRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/24/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class GridRenderer: SceneRenderer {
    private struct GridUniforms {
        static let size = MemoryLayout<Int>.size

        let numLights: Int

        func raw() -> [Int] {
            return [numLights]
        }
    }

    private let clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)

    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var gridVertexBufferQueue: BufferQueue!
    private var gridIndexBufferQueue: BufferQueue!
    private var gridUniformsBufferQueue: BufferQueue!
    private var lightsBufferQueue: BufferQueue!

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        gridVertexBufferQueue = BufferQueue(device: device, length: MemoryLayout<PointMass>.size * 4000)
        gridIndexBufferQueue = BufferQueue(device: device, length: MemoryLayout<UInt16>.size * 6000)

        gridUniformsBufferQueue = BufferQueue(device: device, length: GridUniforms.size)
        lightsBufferQueue = BufferQueue(device: device, length: EntityManager.maxEntities * 3 * MemoryLayout<Float>.size)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        renderPassDescriptor.colorAttachments[0].storeAction = .store

      let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        // TODO: renderPassDescriptor does not set a depthAttachment, but originally we did set a depthstencilstate below...
        // commandEncoder!.setDepthStencilState(depthStencilState)
        commandEncoder!.setRenderPipelineState(pipelineState)

        let grid = GridManager.sharedManager.grid

        let vertexBuffer = gridVertexBufferQueue.nextBuffer
      
        let gridPointMassesPtr = UnsafeRawPointer(&grid.pointMasses).assumingMemoryBound(to: PointMass.self)
        vertexBuffer.copyData(data: gridPointMassesPtr, size: MemoryLayout<PointMass>.size * grid.pointMasses.count)

        let indexBuffer = gridIndexBufferQueue.nextBuffer
        indexBuffer.copyData(data: grid.indices, size: MemoryLayout<UInt16>.size * grid.indices.count)

        let gridUniformsBuffer = gridUniformsBufferQueue.nextBuffer
        let gridUniforms = GridUniforms(numLights: scene.lights.count)
        gridUniformsBuffer.copyData(data: gridUniforms.raw(), size: GridUniforms.size)

        let lightsBuffer = lightsBufferQueue.nextBuffer
        for light in scene.lights {
          lightsBuffer.copyData(data: light.floatBuffer, size: Light.size)
        }

      commandEncoder!.setVertexBuffer(vertexBuffer.buffer, offset: 0, index: 0)
      commandEncoder!.setVertexBuffer(scene.cameraUniformsBuffer!.buffer, offset: 0, index: 1)
      commandEncoder!.setVertexBuffer(gridUniformsBuffer.buffer, offset: 0, index: 2)
      commandEncoder!.setVertexBuffer(lightsBuffer.buffer, offset: 0, index: 3)
      commandEncoder!.drawIndexedPrimitives(type: .line, indexCount: grid.indices.count, indexType: .uint16, indexBuffer: indexBuffer.buffer, indexBufferOffset: 0)
        commandEncoder!.endEncoding()
    }

    private func setup() {
      let defaultLibrary = device.makeDefaultLibrary()!
      let vertexFunction = defaultLibrary.makeFunction(name: "grid_vertex")
      let fragmentFunction = defaultLibrary.makeFunction(name: "grid_fragment")

        let vertexDescriptor = MTLVertexDescriptor()
      vertexDescriptor.attributes[0].format = .float2
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.layouts[0].stride = MemoryLayout<PointMass>.size
      vertexDescriptor.layouts[0].stepFunction = .perVertex

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
      pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexDescriptor = vertexDescriptor

        do {
          pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print (error)
        }

        let depthStencilDescriptor = MTLDepthStencilDescriptor()
      depthStencilDescriptor.depthCompareFunction = .less
      depthStencilDescriptor.isDepthWriteEnabled = true
      depthStencilState = device.makeDepthStencilState(descriptor: depthStencilDescriptor)
    }
}

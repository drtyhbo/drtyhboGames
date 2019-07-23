//
//  Renderer.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/16/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class EntityRenderer: SceneRenderer {
    private let maxVerticesPerEntity = 100

    private let perInstanceUniformsBufferQueue: BufferQueue
    private let vertexBufferQueue: BufferQueue
    private let indexBufferQueue: BufferQueue

    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        perInstanceUniformsBufferQueue = BufferQueue(device: device, length: PerInstanceUniforms.size * EntityManager.maxEntities)
        vertexBufferQueue = BufferQueue(device: device, length: maxVerticesPerEntity * EntityManager.maxEntities)
        indexBufferQueue = BufferQueue(device: device, length: 3 * maxVerticesPerEntity * EntityManager.maxEntities)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let entities = EntityManager.sharedManager.entities
        if entities.count == 0 {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
      renderPassDescriptor.colorAttachments[0].loadAction = .load
      renderPassDescriptor.colorAttachments[0].storeAction = .store

        let perInstanceUniformsBuffer = perInstanceUniformsBufferQueue.nextBuffer
        let vertexBuffer = vertexBufferQueue.nextBuffer
        let indexBuffer = indexBufferQueue.nextBuffer

        var perInstanceUniformsBufferOffset = 0

        var entityName = entities[0].name
        var entityCount = 0
        var currentModel: Model?
        for i in 0..<entities.count {
            let entity = entities[i]

            if currentModel == nil || entity.name != entityName {
                currentModel = entity.model
                entityName = entity.name
                currentModel = entity.model
            }

          let perInstanceUniforms = entity.calculatePerInstanceMatricesWithWorldMatrix(worldMatrix: scene.camera.worldMatrix)
          perInstanceUniformsBuffer.copyData(data: perInstanceUniforms.modelViewMatrix.raw(), size: Matrix4.size())
          perInstanceUniformsBuffer.copyData(data: perInstanceUniforms.normalMatrix.raw(), size: Matrix4.size())
          perInstanceUniformsBuffer.copyData(data: perInstanceUniforms.color.raw(), size: float4.size)
            entityCount += 1

            if i == entities.count - 1 || entities[i + 1].name != entityName {
                let vertexBufferOffset = vertexBuffer.currentOffset
                let indexBufferOffset = indexBuffer.currentOffset

              vertexBuffer.copyData(data: currentModel!.vertexData, size: currentModel!.vertices.count * Vertex.size)
              indexBuffer.copyData(data: currentModel!.indices, size: currentModel!.indices.count * MemoryLayout<UInt16>.size)

              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
              commandEncoder!.setCullMode(.back)
              commandEncoder!.setFrontFacing(.counterClockwise)
              // TODO: Again no depth attachment... hmm
              // commandEncoder!.setDepthStencilState(depthStencilState)
              commandEncoder!.setRenderPipelineState(pipelineState)
              commandEncoder!.setVertexBuffer(vertexBuffer.buffer, offset: vertexBufferOffset, index: 0)
              commandEncoder!.setVertexBuffer(scene.cameraUniformsBuffer!.buffer, offset: 0, index: 1)
              commandEncoder!.setVertexBuffer(perInstanceUniformsBuffer.buffer, offset: perInstanceUniformsBufferOffset, index: 2)
              commandEncoder!.drawIndexedPrimitives(type: .triangle, indexCount: currentModel!.indices.count, indexType: .uint16, indexBuffer: indexBuffer.buffer, indexBufferOffset: indexBufferOffset, instanceCount: entityCount)
                commandEncoder!.endEncoding()

                entityCount = 0
                perInstanceUniformsBufferOffset = perInstanceUniformsBuffer.currentOffset
            }
        }
    }

    private func setup() {
      let defaultLibrary = device.makeDefaultLibrary()!
      let vertexFunction = defaultLibrary.makeFunction(name: "basic_vertex")!
      let fragmentFunction = defaultLibrary.makeFunction(name: "basic_fragment")!

      let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: Vertex.vertexDescriptor(), alphaBlending: true)
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

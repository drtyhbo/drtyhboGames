//
//  SpriteRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private struct SpriteVertex {
    static let size = 32

    var position: float3
    var texCoords: float2
}

class SpriteRenderer: SceneRenderer {
    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var samplerState: MTLSamplerState!

    private let maxSprites = 5

    private let vertexBuffer: MTLBuffer
    private let indexBuffer: MTLBuffer
    private let sharedUniformsBuffer: MTLBuffer
    private let perInstanceUniformsBufferQueue: BufferQueue
    private let spriteTexture: MTLTexture

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        let vertices: [SpriteVertex] = [
            SpriteVertex(position: float3(0, 0, 0), texCoords: float2(0, 0)),
            SpriteVertex(position: float3(1, 0, 0), texCoords: float2(1, 0)),
            SpriteVertex(position: float3(1, 1, 0), texCoords: float2(1, 1)),
            SpriteVertex(position: float3(0, 1, 0), texCoords: float2(0, 1))]
      vertexBuffer = device.makeBuffer(bytes: vertices, length: SpriteVertex.size * 4, options: MTLResourceOptions(rawValue: 0))!

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
      indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.size * 6, options: MTLResourceOptions(rawValue: 0))!

      sharedUniformsBuffer = device.makeBuffer(bytes: Matrix4.makeOrthoWithScreenSize().raw(), length: Matrix4.size(), options: MTLResourceOptions(rawValue: 0))!
        perInstanceUniformsBufferQueue = BufferQueue(device: device, length: Matrix4.size() * maxSprites)

      spriteTexture = UIImage.circleWithRadius(radius: 100, lineWidth: 5, color: UIColor(red: 1, green: 1, blue: 1, alpha: 1)).createMTLTextureForDevice(device: device)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
      renderPassDescriptor.colorAttachments[0].loadAction = .load
      renderPassDescriptor.colorAttachments[0].storeAction = .store

        let perInstanceUniformsBuffer = perInstanceUniformsBufferQueue.nextBuffer
        for sprite in SpriteManager.sharedManager.sprites {
            let perInstanceUniformsBufferOffset = perInstanceUniformsBuffer.currentOffset

            var instanceCount = 0
            for instance in sprite.instances {
                if instance.alpha < 0.01 {
                    continue
                }

                // This is going to be horribly inefficient should we dramatically increase the
                // number of sprites.
              perInstanceUniformsBuffer.copyData(data: instance.modelMatrix.raw(), size: Matrix4.size())
              perInstanceUniformsBuffer.copyData(data: &instance.alpha, size: MemoryLayout<Float>.size)

                instanceCount += 1
            }

            if instanceCount > 0 {
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
                commandEncoder!.setRenderPipelineState(pipelineState)

              commandEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
              commandEncoder!.setVertexBuffer(sharedUniformsBuffer, offset: 0, index: 1)
              commandEncoder!.setVertexBuffer(perInstanceUniformsBuffer.buffer, offset: perInstanceUniformsBufferOffset, index: 2)

              commandEncoder!.setFragmentTexture(spriteTexture, index: 0)
              commandEncoder!.setFragmentSamplerState(samplerState, index: 0)

              commandEncoder!.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: instanceCount)

                commandEncoder!.endEncoding()
            }
        }
    }

    private func setup() {
      let defaultLibrary = device.makeDefaultLibrary()!
      let vertexFunction = defaultLibrary.makeFunction(name: "sprite_vertex")!
      let fragmentFunction = defaultLibrary.makeFunction(name: "sprite_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
      vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

      vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 4

        vertexDescriptor.layouts[0].stride = SpriteVertex.size
      vertexDescriptor.layouts[0].stepFunction = .perVertex

      let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: vertexDescriptor, alphaBlending: true)
        do {
          pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print (error)
        }

        let samplerDescriptor = MTLSamplerDescriptor()
      samplerDescriptor.minFilter = .nearest;
      samplerDescriptor.magFilter = .linear;
      samplerDescriptor.sAddressMode = .clampToZero;
      samplerDescriptor.tAddressMode = .clampToZero;
      samplerState = device.makeSamplerState(descriptor: samplerDescriptor)
    }
}

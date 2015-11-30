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
        vertexBuffer = device.newBufferWithBytes(vertices, length: SpriteVertex.size * 4, options: MTLResourceOptions(rawValue: 0))

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        indexBuffer = device.newBufferWithBytes(indices, length: sizeof(UInt16) * 6, options: MTLResourceOptions(rawValue: 0))

        sharedUniformsBuffer = device.newBufferWithBytes(Matrix4.makeOrthoWithScreenSize().raw(), length: Matrix4.size(), options: MTLResourceOptions(rawValue: 0))
        perInstanceUniformsBufferQueue = BufferQueue(device: device, length: Matrix4.size() * maxSprites)

        spriteTexture = UIImage.circleWithRadius(100, lineWidth: 5, color: UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)).createMTLTextureForDevice(device)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .Load
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

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
                perInstanceUniformsBuffer.copyData(instance.modelMatrix.raw(), size: Matrix4.size())
                perInstanceUniformsBuffer.copyData(&instance.alpha, size: sizeof(Float))

                instanceCount++
            }

            if instanceCount > 0 {
                let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
                commandEncoder.setRenderPipelineState(pipelineState)

                commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
                commandEncoder.setVertexBuffer(sharedUniformsBuffer, offset: 0, atIndex: 1)
                commandEncoder.setVertexBuffer(perInstanceUniformsBuffer.buffer, offset: perInstanceUniformsBufferOffset, atIndex: 2)

                commandEncoder.setFragmentTexture(spriteTexture, atIndex: 0)
                commandEncoder.setFragmentSamplerState(samplerState, atIndex: 0)

                commandEncoder.drawIndexedPrimitives(.Triangle, indexCount: 6, indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: instanceCount)

                commandEncoder.endEncoding()
            }
        }
    }

    private func setup() {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexFunction = defaultLibrary.newFunctionWithName("sprite_vertex")!
        let fragmentFunction = defaultLibrary.newFunctionWithName("sprite_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.attributes[1].format = .Float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = sizeof(Float) * 4

        vertexDescriptor.layouts[0].stride = SpriteVertex.size
        vertexDescriptor.layouts[0].stepFunction = .PerVertex

        let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: vertexDescriptor, alphaBlending: true)
        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch let error {
            print (error)
        }

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .Nearest;
        samplerDescriptor.magFilter = .Linear;
        samplerDescriptor.sAddressMode = .ClampToZero;
        samplerDescriptor.tAddressMode = .ClampToZero;
        samplerState = device.newSamplerStateWithDescriptor(samplerDescriptor)
    }
}
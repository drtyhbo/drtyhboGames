//
//  ParticleRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class ParticleRenderer: Renderer {
    private struct ParticleRendererUniforms {
        var currentTime: Float
    }

    private var pipelineState: MTLRenderPipelineState!
    private var clearRenderPassDescriptor: MTLRenderPassDescriptor!
    private var depthStencilState: MTLDepthStencilState!

    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var particlesBufferQueue: BufferQueue!
    private var laserParticlesBufferQueue: BufferQueue!
    private var particleRendererUniformsQueue: BufferQueue!

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        vertexBuffer = device.newBufferWithLength(sizeof(Float) * 12, options: MTLResourceOptions(rawValue: 0))
        let vertices: [Float] = [-0.5, 0.5, 0, 1, 0.5, 0.5, 0, 1, 0.5, -0.5, 0, 0.5, -0.5, -0.5, 0, 0.5]
        memcpy(vertexBuffer.contents(), vertices, sizeof(Float) * 16)

        indexBuffer = device.newBufferWithLength(sizeof(UInt16) * 6, options: MTLResourceOptions(rawValue: 0))
        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        memcpy(indexBuffer.contents(), indices, sizeof(UInt16) * 6)

        particlesBufferQueue = BufferQueue(device: device, length: sizeof(Particle) * ParticleManager.maxParticles)
        laserParticlesBufferQueue = BufferQueue(device: device, length: sizeof(Particle) * ParticleManager.maxParticles)
        particleRendererUniformsQueue = BufferQueue(device: device, length: sizeof(ParticleRendererUniforms))

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    func renderParticlesWithSharedUniformsBuffer(sharedUniformsBuffer: Buffer, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        if ParticleManager.sharedManager.particles.count == 0 {
            return
        }

        var particleRendererUniforms = ParticleRendererUniforms(currentTime: GameTimer.sharedTimer.currentTime)
        let particleRendererUniformsBuffer = particleRendererUniformsQueue.nextBuffer
        particleRendererUniformsBuffer.copyData(&particleRendererUniforms, size: sizeof(ParticleRendererUniforms))

        let particlesBuffer = particlesBufferQueue.nextBuffer
        particlesBuffer.copyData(ParticleManager.sharedManager.particles, size: sizeof(Particle) * ParticleManager.sharedManager.particles.count)

        renderParticlesWithBuffer(particlesBuffer, particleRendererUniformsBuffer: particleRendererUniformsBuffer, sharedUniformsBuffer: sharedUniformsBuffer, numberOfParticles: ParticleManager.sharedManager.particles.count, toCommandBuffer: commandBuffer, outputTexture: outputTexture)

        let laserParticlesBuffer = laserParticlesBufferQueue.nextBuffer
        laserParticlesBuffer.copyData(ParticleManager.sharedManager.laserParticles, size: sizeof(Particle) * ParticleManager.sharedManager.laserParticles.count)

        renderParticlesWithBuffer(laserParticlesBuffer, particleRendererUniformsBuffer: particleRendererUniformsBuffer, sharedUniformsBuffer: sharedUniformsBuffer, numberOfParticles: ParticleManager.sharedManager.laserParticles.count, toCommandBuffer: commandBuffer, outputTexture: outputTexture)
    }

    private func renderParticlesWithBuffer(particlesBuffer: Buffer, particleRendererUniformsBuffer: Buffer, sharedUniformsBuffer: Buffer, numberOfParticles: Int, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        if numberOfParticles == 0 {
            return
        }

        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .Load
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        commandEncoder.setDepthStencilState(depthStencilState)
        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(sharedUniformsBuffer.buffer, offset: 0, atIndex: 1)
        commandEncoder.setVertexBuffer(particlesBuffer.buffer, offset: 0, atIndex: 2)
        commandEncoder.setVertexBuffer(particleRendererUniformsBuffer.buffer, offset: 0, atIndex: 3)
        commandEncoder.drawIndexedPrimitives(.Triangle, indexCount: 6, indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: numberOfParticles)
        commandEncoder.endEncoding()
    }

    private func setup() {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexFunction = defaultLibrary.newFunctionWithName("particle_vertex")!
        let fragmentFunction = defaultLibrary.newFunctionWithName("particle_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.attributes[1].format = .Float
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = sizeof(Float) * 3

        vertexDescriptor.layouts[0].stride = sizeof(Float) * 4
        vertexDescriptor.layouts[0].stepFunction = .PerVertex

        let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: vertexDescriptor, alphaBlending: true)
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
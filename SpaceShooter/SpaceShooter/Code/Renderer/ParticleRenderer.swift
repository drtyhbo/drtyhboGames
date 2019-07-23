//
//  ParticleRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class ParticleRenderer: SceneRenderer {
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
      vertexBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 12, options: MTLResourceOptions(rawValue: 0))
        let vertices: [Float] = [-0.5, 0.5, 0, 1, 0.5, 0.5, 0, 1, 0.5, -0.5, 0, 0.5, -0.5, -0.5, 0, 0.5]
        memcpy(vertexBuffer.contents(), vertices, MemoryLayout<Float>.size * 16)

      indexBuffer = device.makeBuffer(length: MemoryLayout<UInt16>.size * 6, options: MTLResourceOptions(rawValue: 0))
        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        memcpy(indexBuffer.contents(), indices, MemoryLayout<UInt16>.size * 6)

        particlesBufferQueue = BufferQueue(device: device, length: MemoryLayout<Particle>.size * ParticleManager.maxParticles)
        laserParticlesBufferQueue = BufferQueue(device: device, length: MemoryLayout<Particle>.size * ParticleManager.maxParticles)
        particleRendererUniformsQueue = BufferQueue(device: device, length: MemoryLayout<ParticleRendererUniforms>.size)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        var particleRendererUniforms = ParticleRendererUniforms(currentTime: GameTimer.sharedTimer.currentTime)
        let particleRendererUniformsBuffer = particleRendererUniformsQueue.nextBuffer
      particleRendererUniformsBuffer.copyData(data: &particleRendererUniforms, size: MemoryLayout<ParticleRendererUniforms>.size)

        if ParticleManager.sharedManager.particles.count > 0 {
            let particlesBuffer = particlesBufferQueue.nextBuffer
          particlesBuffer.copyData(data: ParticleManager.sharedManager.particles, size: MemoryLayout<Particle>.size * ParticleManager.sharedManager.particles.count)

          renderParticlesWithBuffer(particlesBuffer: particlesBuffer, particleRendererUniformsBuffer: particleRendererUniformsBuffer, cameraUniformsBuffer: scene.cameraUniformsBuffer!, numberOfParticles: ParticleManager.sharedManager.particles.count, toCommandBuffer: commandBuffer, outputTexture: outputTexture)
        }

        if ParticleManager.sharedManager.laserParticles.count > 0 {
            let laserParticlesBuffer = laserParticlesBufferQueue.nextBuffer
          laserParticlesBuffer.copyData(data: ParticleManager.sharedManager.laserParticles, size: MemoryLayout<Particle>.size * ParticleManager.sharedManager.laserParticles.count)

          renderParticlesWithBuffer(particlesBuffer: laserParticlesBuffer, particleRendererUniformsBuffer: particleRendererUniformsBuffer, cameraUniformsBuffer: scene.cameraUniformsBuffer!, numberOfParticles: ParticleManager.sharedManager.laserParticles.count, toCommandBuffer: commandBuffer, outputTexture: outputTexture)
        }
    }

    private func renderParticlesWithBuffer(particlesBuffer: Buffer, particleRendererUniformsBuffer: Buffer, cameraUniformsBuffer: Buffer, numberOfParticles: Int, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
      renderPassDescriptor.colorAttachments[0].loadAction = .load
      renderPassDescriptor.colorAttachments[0].storeAction = .store

      let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
      // TODO: another no depth stencil attachment issue...
        // commandEncoder!.setDepthStencilState(depthStencilState)
        commandEncoder!.setRenderPipelineState(pipelineState)

      commandEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
      commandEncoder!.setVertexBuffer(cameraUniformsBuffer.buffer, offset: 0, index: 1)
      commandEncoder!.setVertexBuffer(particlesBuffer.buffer, offset: 0, index: 2)
      commandEncoder!.setVertexBuffer(particleRendererUniformsBuffer.buffer, offset: 0, index: 3)
      commandEncoder!.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: numberOfParticles)
        commandEncoder!.endEncoding()
    }

    private func setup() {
      let defaultLibrary = device.makeDefaultLibrary()!
      let vertexFunction = defaultLibrary.makeFunction(name: "particle_vertex")!
      let fragmentFunction = defaultLibrary.makeFunction(name: "particle_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
      vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

      vertexDescriptor.attributes[1].format = .float
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 3

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 4
      vertexDescriptor.layouts[0].stepFunction = .perVertex

      let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction: vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: vertexDescriptor, alphaBlending: true)
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

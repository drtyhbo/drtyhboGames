//
//  RenderManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/18/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import MetalPerformanceShaders
import Metal
import QuartzCore

class RenderManager {
  private let inflightSemaphore = DispatchSemaphore(value: Constants.numberOfInflightFrames)
    private let commandQueue: MTLCommandQueue
    private let device: MTLDevice
    private let metalLayer: CAMetalLayer

    private var drawable: CAMetalDrawable!
    private var commandBuffer: MTLCommandBuffer!

    private var cameraUniformsBufferQueue: BufferQueue!

    private let entityRenderer: EntityRenderer
    private let particleRenderer: ParticleRenderer
    private let gridRenderer: GridRenderer
    private let textRenderer: TextRenderer
    private let spriteRenderer: SpriteRenderer

    private let highPassFilter: HighPassFilter
    private let gaussianFilter: GaussianFilter
    private let gaussianBlendFilter: BlendFilter
    private let bloomBlendFilter: BlendFilter

    init(device: MTLDevice, metalLayer: CAMetalLayer!) {
        self.device = device
        self.metalLayer = metalLayer

      commandQueue = device.makeCommandQueue()!

        cameraUniformsBufferQueue = BufferQueue(device: device, length: CameraUniforms.size)

        entityRenderer = EntityRenderer(device: device, commandQueue: commandQueue)
        particleRenderer = ParticleRenderer(device: device, commandQueue: commandQueue)
        gridRenderer = GridRenderer(device: device, commandQueue: commandQueue)
        textRenderer = TextRenderer(device: device, commandQueue: commandQueue)
        spriteRenderer = SpriteRenderer(device: device, commandQueue: commandQueue)

        highPassFilter = HighPassFilter(device: device, commandQueue: commandQueue)
        gaussianFilter = GaussianFilter(device: device, commandQueue: commandQueue)
        gaussianBlendFilter = BlendFilter(device: device, commandQueue: commandQueue, blendType: .Additive)
        bloomBlendFilter = BlendFilter(device: device, commandQueue: commandQueue, blendType: .Default)
    }

    func beginFrame() {
      inflightSemaphore.wait(timeout: .distantFuture)
      
        drawable = metalLayer.nextDrawable()
        if drawable == nil {
            return
        }

      commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
              strongSelf.inflightSemaphore.signal()
            }
            return
        }
    }

    func endFrame() {
      commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    func renderScene(scene: Scene) {
        let cameraUniforms = scene.camera.cameraUniforms
        let cameraUniformsBuffer = cameraUniformsBufferQueue.nextBuffer
      
      cameraUniformsBuffer.copyData(data: cameraUniforms.projectionMatrix.raw(), size: Matrix4.size())
      cameraUniformsBuffer.copyData(data: cameraUniforms.worldMatrix.raw(), size: Matrix4.size())
      scene.cameraUniformsBuffer = cameraUniformsBuffer

      let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.bgra8Unorm, width: drawable.texture.width, height: drawable.texture.height, mipmapped: false)
      textureDescriptor.usage = [.renderTarget,.shaderRead]
      let outputTexture = device.makeTexture(descriptor: textureDescriptor)
      clearTexture(texture: drawable.texture)

      gridRenderer.renderScene(scene: scene, toCommandBuffer: commandBuffer, outputTexture: outputTexture!)
      entityRenderer.renderScene(scene: scene, toCommandBuffer: commandBuffer, outputTexture: outputTexture!)
      particleRenderer.renderScene(scene: scene, toCommandBuffer: commandBuffer, outputTexture: outputTexture!)

      applyBloomFilterToTexture(texture: outputTexture!, outputTexture: drawable.texture, commandBuffer: commandBuffer)

      textRenderer.renderScene(scene: scene, toCommandBuffer: commandBuffer, outputTexture: drawable.texture)
      spriteRenderer.renderScene(scene: scene, toCommandBuffer: commandBuffer, outputTexture: drawable.texture)
    }

    private func clearTexture(texture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
      renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
      renderPassDescriptor.colorAttachments[0].storeAction = .store

      let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
      commandEncoder!.endEncoding()
    }

    private func applyBloomFilterToTexture(texture: MTLTexture, outputTexture: MTLTexture, commandBuffer: MTLCommandBuffer) {
      let highPassTexture = highPassFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: texture)
      let gaussianTexture = gaussianFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: highPassTexture)

      gaussianBlendFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: gaussianTexture, outputTexture: texture)
      bloomBlendFilter.renderToCommandEncoder(commandBuffer: commandBuffer, inputTexture: texture, outputTexture: outputTexture)
    }
}

//
//  RenderManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 10/18/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

class RenderManager {
    private let inflightSemaphore = dispatch_semaphore_create(Constants.numberOfInflightFrames)
    private let commandQueue: MTLCommandQueue
    private let device: MTLDevice
    private let metalLayer: CAMetalLayer

    private var drawable: CAMetalDrawable!
    private var commandBuffer: MTLCommandBuffer!

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

        commandQueue = device.newCommandQueue()

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
        dispatch_semaphore_wait(inflightSemaphore, DISPATCH_TIME_FOREVER)

        drawable = metalLayer.nextDrawable()
        if drawable == nil {
            return
        }

        commandBuffer = commandQueue.commandBuffer()
        commandBuffer.addCompletedHandler{ [weak self] commandBuffer in
            if let strongSelf = self {
                dispatch_semaphore_signal(strongSelf.inflightSemaphore)
            }
            return
        }
    }

    func endFrame() {
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }

    func renderWithLights(lights: [Light], sharedUniformsBuffer: Buffer) {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.BGRA8Unorm, width: drawable.texture.width, height: drawable.texture.height, mipmapped: false)
        let outputTexture = device.newTextureWithDescriptor(textureDescriptor)

        gridRenderer.renderGrid(GridManager.sharedManager.grid, sharedUniformsBuffer: sharedUniformsBuffer, lights: lights, toCommandBuffer: commandBuffer, outputTexture: drawable.texture)
        entityRenderer.renderEntities(EntityManager.sharedManager.entities, sharedUniformsBuffer: sharedUniformsBuffer, toCommandBuffer: commandBuffer, outputTexture: outputTexture)
        particleRenderer.renderParticlesWithSharedUniformsBuffer(sharedUniformsBuffer, toCommandBuffer: commandBuffer, outputTexture: outputTexture)

        applyBloomFilterToTexture(outputTexture, outputTexture: drawable.texture, commandBuffer: commandBuffer)

        spriteRenderer.renderSpritesToCommandBuffer(commandBuffer, outputTexture: drawable.texture)
        textRenderer.renderText(sharedUniformsBuffer, toCommandBuffer: commandBuffer, outputTexture: drawable.texture)
    }

    private func clearTexture(texture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        commandEncoder.endEncoding()
    }

    var startTime = NSDate()

    private func applyBloomFilterToTexture(texture: MTLTexture, outputTexture: MTLTexture, commandBuffer: MTLCommandBuffer) {
        let highPassTexture = highPassFilter.renderToCommandEncoder(commandBuffer, inputTexture: texture)
        let gaussianTexture = gaussianFilter.renderToCommandEncoder(commandBuffer, inputTexture: highPassTexture)

        gaussianBlendFilter.renderToCommandEncoder(commandBuffer, inputTexture: gaussianTexture, outputTexture: texture)
        bloomBlendFilter.renderToCommandEncoder(commandBuffer, inputTexture: texture, outputTexture: outputTexture)
    }

    private func saveTexture(texture: MTLTexture, toFileWithName name: String) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let image = UIImage.MTLTextureToUIImage(texture)
        UIImagePNGRepresentation(image)?.writeToFile(documentsPath + "/\(name).png", atomically: true)
    }
}
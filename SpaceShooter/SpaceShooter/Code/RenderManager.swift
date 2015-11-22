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
    private let metalLayer: CAMetalLayer

    private var drawable: CAMetalDrawable!
    private var commandBuffer: MTLCommandBuffer!

    private let entityRenderer: EntityRenderer
    private let particleRenderer: ParticleRenderer
    private let gridRenderer: GridRenderer
    private let textRenderer: TextRenderer
    private let spriteRenderer: SpriteRenderer

    private let bloomFilter: BloomFilter
    private let copyFilter: CopyFilter
    private let inputTextureQueue: TextureQueue

    init(device: MTLDevice, metalLayer: CAMetalLayer!) {
        self.metalLayer = metalLayer

        commandQueue = device.newCommandQueue()

        entityRenderer = EntityRenderer(device: device, commandQueue: commandQueue)
        particleRenderer = ParticleRenderer(device: device, commandQueue: commandQueue)
        gridRenderer = GridRenderer(device: device, commandQueue: commandQueue)
        textRenderer = TextRenderer(device: device, commandQueue: commandQueue)
        spriteRenderer = SpriteRenderer(device: device, commandQueue: commandQueue)

        bloomFilter = BloomFilter(device: device)
        copyFilter = CopyFilter()

        let screenSize = UIScreen.mainScreen().bounds.size
        inputTextureQueue = TextureQueue(device: device, width: Int(screenSize.width), height: Int(screenSize.height))
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

        entityRenderer.beginFrameWithDrawable(drawable, commandBuffer: commandBuffer)
        particleRenderer.beginFrameWithDrawable(drawable, commandBuffer: commandBuffer)
        gridRenderer.beginFrameWithDrawable(drawable, commandBuffer: commandBuffer)
        textRenderer.beginFrameWithDrawable(drawable, commandBuffer: commandBuffer)
        spriteRenderer.beginFrameWithDrawable(drawable, commandBuffer: commandBuffer)
    }

    func endFrame() {
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
    }

    func renderWithLights(lights: [Light], sharedUniformsBuffer: Buffer) {
        renderGrid(GridManager.sharedManager.grid, sharedUniformsBuffer: sharedUniformsBuffer, lights: lights)
        renderEntities(EntityManager.sharedManager.entities, sharedUniformsBuffer: sharedUniformsBuffer)
        renderParticlesWithSharedUniformsBuffer(sharedUniformsBuffer)
        spriteRenderer.renderSprites()
//        applyBloomFilter()

        textRenderer.renderText(sharedUniformsBuffer)
    }

    private func renderEntities(entities: [Entity], sharedUniformsBuffer: Buffer) {
        entityRenderer.renderEntities(entities, sharedUniformsBuffer: sharedUniformsBuffer)
    }

    private func renderParticlesWithSharedUniformsBuffer(sharedUniformsBuffer: Buffer) {
        particleRenderer.renderParticlesWithSharedUniformsBuffer(sharedUniformsBuffer)
    }

    private func renderGrid(grid: Grid, sharedUniformsBuffer: Buffer, lights: [Light]) {
        gridRenderer.renderGrid(grid, sharedUniformsBuffer: sharedUniformsBuffer, lights: lights)
    }

    private func applyBloomFilter() {
        let inputTexture = inputTextureQueue.nextTexture.texture
        bloomFilter.encodeToCommandBuffer(commandBuffer, sourceTexture: drawable.texture, destinationTexture: inputTexture)
        copyFilter.encodeToCommandBuffer(commandBuffer, sourceTexture: inputTexture, destinationTexture: drawable.texture)

    }
}
//
//  Filter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private struct FilterVertex {
    static let size = 32

    let position: float3
    let texCoords: float2
}

class FilterRenderer: Renderer {
    private let vertexBuffer: MTLBuffer
    private let indexBuffer: MTLBuffer
    private let sharedUniformsBuffer: MTLBuffer

    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var samplerState: MTLSamplerState!
    private var outputTextureQueue: TextureQueue!

    // MARK: init

    init(device: MTLDevice, commandQueue: MTLCommandQueue, vertexFunction: String, fragmentFunction: String, alphaBlending: Bool) {
        let vertices: [FilterVertex] = [
            FilterVertex(position: float3(0, 0, 0), texCoords: float2(0, 0)),
            FilterVertex(position: float3(1, 0, 0), texCoords: float2(1, 0)),
            FilterVertex(position: float3(1, 1, 0), texCoords: float2(1, 1)),
            FilterVertex(position: float3(0, 1, 0), texCoords: float2(0, 1))]
        vertexBuffer = device.newBufferWithBytes(vertices, length: FilterVertex.size * 4, options: MTLResourceOptions(rawValue: 0))

        let indices: [UInt16] = [0, 1, 2, 0, 2, 3]
        indexBuffer = device.newBufferWithBytes(indices, length: sizeof(UInt16) * 6, options: MTLResourceOptions(rawValue: 0))

        sharedUniformsBuffer = device.newBufferWithBytes(Matrix4.makeOrthoLeft(0, right: 1, bottom: 1, top: 0, nearZ: -1, farZ: 1).raw(), length: Matrix4.size(), options: MTLResourceOptions(rawValue: 0))

        super.init(device: device, commandQueue: commandQueue)

        setupWithVertexFunction(vertexFunction, fragmentFunction: fragmentFunction, alphaBlending: alphaBlending)
    }

    // MARK: Public

    func renderToCommandEncoder(commandBuffer: MTLCommandBuffer, inputTexture: MTLTexture) -> MTLTexture {
        if outputTextureQueue == nil {
            outputTextureQueue = TextureQueue(device: device, width: inputTexture.width, height: inputTexture.height)
        }

        let outputTexture = outputTextureQueue.nextTexture.texture
        renderToCommandEncoder(commandBuffer, inputTexture: inputTexture, outputTexture: outputTexture)

        return outputTexture
    }

    func renderToCommandEncoder(commandBuffer: MTLCommandBuffer, inputTexture: MTLTexture, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .Load
        renderPassDescriptor.colorAttachments[0].storeAction = .Store
        customizeRenderPassDescriptor(renderPassDescriptor)

        let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        commandEncoder.setRenderPipelineState(pipelineState)

        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        commandEncoder.setVertexBuffer(sharedUniformsBuffer, offset: 0, atIndex: 1)
        commandEncoder.setFragmentTexture(inputTexture, atIndex: 0)
        commandEncoder.setFragmentSamplerState(samplerState, atIndex: 0)

        customizeCommandEncoder(commandEncoder, inputTexture: inputTexture)

        commandEncoder.drawIndexedPrimitives(.Triangle, indexCount: 6, indexType: .UInt16, indexBuffer: indexBuffer, indexBufferOffset: 0, instanceCount: 1)

        commandEncoder.endEncoding()
    }

    // MARK: Override

    func customizeCommandEncoder(commandEncoder: MTLRenderCommandEncoder, inputTexture: MTLTexture) {
    }

    func customizeRenderPassDescriptor(renderPassDescriptor: MTLRenderPassDescriptor) {
    }

    // MARK: Private

    private func setupWithVertexFunction(vertexFunction: String, fragmentFunction: String, alphaBlending: Bool) {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexFunction = defaultLibrary.newFunctionWithName(vertexFunction)!
        let fragmentFunction = defaultLibrary.newFunctionWithName(fragmentFunction)!

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.attributes[1].format = .Float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = sizeof(Float) * 4

        vertexDescriptor.layouts[0].stride = FilterVertex.size
        vertexDescriptor.layouts[0].stepFunction = .PerVertex

        let pipelineDescriptor = pipelineDescriptorWithVertexFunction(vertexFunction, fragmentFunction: fragmentFunction, vertexDescriptor: vertexDescriptor, alphaBlending: alphaBlending)
        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch let error {
            print (error)
        }

        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .Linear;
        samplerDescriptor.magFilter = .Linear;
        samplerDescriptor.sAddressMode = .ClampToZero;
        samplerDescriptor.tAddressMode = .ClampToZero;
        samplerState = device.newSamplerStateWithDescriptor(samplerDescriptor)
    }
}
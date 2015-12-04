//
//  TextRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/13/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private class TextRendererData {
    weak var label: Label!
    var text = "" {
        didSet {
            if text != oldValue {
                updateMesh()
            }
        }
    }

    private(set) var mesh: MBETextMesh?
    private(set) var textRendererUniformsBufferQueue: BufferQueue!

    private let textRendererUniformsSize: Int = Matrix4.size() * 2 + sizeof(Float) * 4
    private let device: MTLDevice
    private let fontAtlas: MBEFontAtlas
    private let orthoProjectionMatrix = Matrix4.makeOrthoWithScreenSizeAndScale()

    init(device: MTLDevice, fontAtlas: MBEFontAtlas, label: Label) {
        self.device = device
        self.fontAtlas = fontAtlas
        self.label = label
        textRendererUniformsBufferQueue = BufferQueue(device: device, length: textRendererUniformsSize)
    }

    func getNextTextRendererUniformsBuffer() -> Buffer {
        var xTranslation = label.position[0]
        if label.alignment.contains(.Right) {
            xTranslation = label.position[0] - Float(mesh!.rect.size.width)
        } else if label.alignment.contains(.Center) {
            xTranslation = label.position[0] - Float(mesh!.rect.size.width) / 2
        }

        var yTranslation = label.position[1]
        if label.alignment.contains(.Bottom) {
            yTranslation = label.position[1] + Float(mesh!.rect.size.height)
        } else if label.alignment.contains(.Middle) {
            yTranslation = label.position[1] - Float(mesh!.rect.size.height)
        }

        let worldMatrix = Matrix4()
        worldMatrix.translate(xTranslation, y: yTranslation, z: 0)

        let textRendererUniformsBuffer = textRendererUniformsBufferQueue.nextBuffer
        textRendererUniformsBuffer.copyData(orthoProjectionMatrix.raw(), size: Matrix4.size())
        textRendererUniformsBuffer.copyData(worldMatrix.raw(), size: Matrix4.size())

        var color = float4(label.color, label.alpha)
        textRendererUniformsBuffer.copyData(&color, size: sizeof(Float) * 4)

        return textRendererUniformsBuffer
    }

    private func updateMesh() {
        let size = UIScreen.mainScreen().bounds.size
        mesh = MBETextMesh(string: text, inRect: CGRect(x: CGFloat(label.position.x), y: CGFloat(label.position.y), width: size.width, height: size.height), withFontAtlas: fontAtlas, atSize: CGFloat(label.fontSize), device: device)
    }
}

class TextRenderer: SceneRenderer {
    private var pipelineState: MTLRenderPipelineState!
    private var depthStencilState: MTLDepthStencilState!
    private var samplerState: MTLSamplerState!

    private let fontTextureSize = 2048

    private let fontAtlas: MBEFontAtlas
    private let fontTexture: MTLTexture

    override init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        if let filePath = NSBundle.mainBundle().pathForResource("FontAtlas", ofType: "data"), fontAtlasData = NSData(contentsOfFile: filePath), archivedFontAtlas = NSKeyedUnarchiver.unarchiveObjectWithData(fontAtlasData) as? MBEFontAtlas {
            fontAtlas = archivedFontAtlas
        } else {
            fontAtlas = MBEFontAtlas(font: UIFont.boldSystemFontOfSize(48), textureSize: fontTextureSize)
        }

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.R8Unorm, width: fontTextureSize, height: fontTextureSize, mipmapped: false)
        fontTexture = device.newTextureWithDescriptor(textureDescriptor)
        fontTexture.replaceRegion(MTLRegionMake2D(0, 0, fontTextureSize, fontTextureSize), mipmapLevel: 0, withBytes: fontAtlas.textureData.bytes, bytesPerRow: fontTextureSize)

        super.init(device: device, commandQueue: commandQueue)

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .Load
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        for label in TextManager.sharedManager.labels {
            if label.alpha < 0.01 {
                continue
            }

            if label.textRendererData == nil {
                label.textRendererData = TextRendererData(device: device, fontAtlas: fontAtlas, label: label)
            }

            let textRendererData = label.textRendererData as! TextRendererData
            textRendererData.text = label.text

            if let mesh = textRendererData.mesh {
                let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
                commandEncoder.setRenderPipelineState(pipelineState)

                let textRendererUniformsBuffer = textRendererData.getNextTextRendererUniformsBuffer()

                commandEncoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, atIndex: 0)
                commandEncoder.setVertexBuffer(textRendererUniformsBuffer.buffer, offset: 0, atIndex: 1)

                commandEncoder.setFragmentBuffer(textRendererUniformsBuffer.buffer, offset: 0, atIndex: 0)
                commandEncoder.setFragmentTexture(fontTexture, atIndex: 0)
                commandEncoder.setFragmentSamplerState(samplerState, atIndex: 0)
                commandEncoder.drawIndexedPrimitives(.Triangle, indexCount: textRendererData.mesh!.indexBuffer.length / sizeof(UInt16), indexType: .UInt16, indexBuffer: mesh.indexBuffer, indexBufferOffset: 0)

                commandEncoder.endEncoding()
            }
        }
    }

    private func setup() {
        let defaultLibrary = device.newDefaultLibrary()!
        let vertexFunction = defaultLibrary.newFunctionWithName("text_vertex")!
        let fragmentFunction = defaultLibrary.newFunctionWithName("text_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .Float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

        vertexDescriptor.attributes[1].format = .Float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = sizeof(Float) * 4

        vertexDescriptor.layouts[0].stride = sizeof(MBEVertex)
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
//
//  TextRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/13/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

private struct TextRendererUniforms {
    static let size = Matrix4.size() * 2

    let projectionMatrix: Matrix4
    let worldMatrix: Matrix4
}

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
    private(set) var textRendererUniformsBuffer: MTLBuffer!

    private let device: MTLDevice
    private let fontAtlas: MBEFontAtlas

    init(device: MTLDevice, fontAtlas: MBEFontAtlas, label: Label) {
        self.device = device
        self.fontAtlas = fontAtlas
        self.label = label
    }

    private func updateMesh() {
        let size = UIScreen.mainScreen().bounds.size
        mesh = MBETextMesh(string: text, inRect: CGRect(x: CGFloat(label.position.x), y: CGFloat(label.position.y), width: size.width, height: size.height), withFontAtlas: fontAtlas, atSize: 32, device: device)

        textRendererUniformsBuffer = device.newBufferWithLength(TextRendererUniforms.size, options: MTLResourceOptions(rawValue: 0))

        let orthoProjectionMatrix = Matrix4.makeOrthoWithScreenSizeAndScale()
        let worldMatrix = Matrix4()
        if label.alignment == .Left {
            worldMatrix.translate(label.position[0], y: label.position[1], z: 0)
        } else {
            worldMatrix.translate(label.position[0] - Float(mesh!.rect.size.width), y: label.position[1], z: 0)
        }

        memcpy(textRendererUniformsBuffer.contents(), orthoProjectionMatrix.raw(), Matrix4.size())
        memcpy(textRendererUniformsBuffer.contents() + Matrix4.size(), worldMatrix.raw(), Matrix4.size())
    }
}

class TextRenderer: Renderer {
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

    func renderText(sharedUniformsBuffer: Buffer) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Load
        renderPassDescriptor.colorAttachments[0].storeAction = .Store

        for label in TextManager.sharedManager.labels {
            if label.textRendererData == nil {
                label.textRendererData = TextRendererData(device: device, fontAtlas: fontAtlas, label: label)
            }

            let textRendererData = label.textRendererData as! TextRendererData
            textRendererData.text = label.text

            if let mesh = textRendererData.mesh {
                let commandEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
                commandEncoder.setRenderPipelineState(pipelineState)

                commandEncoder.setVertexBuffer(mesh.vertexBuffer, offset: 0, atIndex: 0)
                commandEncoder.setVertexBuffer(textRendererData.textRendererUniformsBuffer, offset: 0, atIndex: 1)

                commandEncoder.setFragmentBuffer(textRendererData.textRendererUniformsBuffer, offset: 0, atIndex: 0)
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
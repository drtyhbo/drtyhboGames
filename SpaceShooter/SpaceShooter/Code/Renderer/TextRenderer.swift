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

    private let textRendererUniformsSize: Int = Matrix4.size() * 2 + MemoryLayout<Float>.size * 4
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
        let labelScale = label.scale
      worldMatrix!.translate(xTranslation, y: yTranslation, z: 0)
      worldMatrix!.scale(labelScale, y: labelScale, z: 1)

        let textRendererUniformsBuffer = textRendererUniformsBufferQueue.nextBuffer
      textRendererUniformsBuffer.copyData(data: orthoProjectionMatrix.raw(), size: Matrix4.size())
      textRendererUniformsBuffer.copyData(data: worldMatrix!.raw(), size: Matrix4.size())

        var color = float4(label.color, label.alpha)
      textRendererUniformsBuffer.copyData(data: &color, size: MemoryLayout<Float>.size * 4)

        return textRendererUniformsBuffer
    }

    private func updateMesh() {
      let size = UIScreen.main.bounds.size
      mesh = MBETextMesh(string: text, in: CGRect(x: 0, y: 0, width: size.width, height: size.height), with: fontAtlas, atSize: CGFloat(label.fontSize), device: device)
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
      if let filePath = Bundle.main.path(forResource: "FontAtlas", ofType: "data"), let fontAtlasData = NSData(contentsOfFile: filePath), let archivedFontAtlas = NSKeyedUnarchiver.unarchiveObject(with: fontAtlasData as Data) as? MBEFontAtlas {
            fontAtlas = archivedFontAtlas
        } else {
            fontAtlas = MBEFontAtlas(font: UIFont(name: "SFDistantGalaxy", size: 64), textureSize: fontTextureSize)

          let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
          let data = NSKeyedArchiver.archivedData(withRootObject: fontAtlas)
          do {
              try data.write(to: URL(fileURLWithPath: "\(documentsDirectory)/FontAtlas.data"), options: [.atomicWrite])
          } catch {
            // NOOP
          }
        }

      let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r8Unorm, width: fontTextureSize, height: fontTextureSize, mipmapped: false)
      fontTexture = device.makeTexture(descriptor: textureDescriptor)!

      super.init(device: device, commandQueue: commandQueue)

      fontAtlas.textureData.withUnsafeBytes({ [unowned self] (td) in
        fontTexture.replace(region: MTLRegionMake2D(0, 0, fontTextureSize, fontTextureSize), mipmapLevel: 0, withBytes: td, bytesPerRow: fontTextureSize)
      })

        setup()
    }

    override func renderScene(scene: Scene, toCommandBuffer commandBuffer: MTLCommandBuffer, outputTexture: MTLTexture) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
      renderPassDescriptor.colorAttachments[0].loadAction = .load
      renderPassDescriptor.colorAttachments[0].storeAction = .store

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
              let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
              commandEncoder!.setRenderPipelineState(pipelineState)

                let textRendererUniformsBuffer = textRendererData.getNextTextRendererUniformsBuffer()

              commandEncoder!.setVertexBuffer(mesh.vertexBuffer, offset: 0, index: 0)
              commandEncoder!.setVertexBuffer(textRendererUniformsBuffer.buffer, offset: 0, index: 1)

              commandEncoder!.setFragmentBuffer(textRendererUniformsBuffer.buffer, offset: 0, index: 0)
              commandEncoder!.setFragmentTexture(fontTexture, index: 0)
              commandEncoder!.setFragmentSamplerState(samplerState, index: 0)
              commandEncoder!.drawIndexedPrimitives(type: .triangle, indexCount: textRendererData.mesh!.indexBuffer.length / MemoryLayout<UInt16>.size, indexType: .uint16, indexBuffer: mesh.indexBuffer, indexBufferOffset: 0)

                commandEncoder!.endEncoding()
            }
        }
    }

    private func setup() {
      let defaultLibrary = device.makeDefaultLibrary()!
      let vertexFunction = defaultLibrary.makeFunction(name: "text_vertex")!
      let fragmentFunction = defaultLibrary.makeFunction(name: "text_fragment")!

        let vertexDescriptor = MTLVertexDescriptor()
      vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

      vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 4

        vertexDescriptor.layouts[0].stride = MemoryLayout<MBEVertex>.size
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

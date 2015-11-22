//
//  TextureQueue.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Texture {
    let texture: MTLTexture

    init(texture: MTLTexture) {
        self.texture = texture
    }
}

class TextureQueue {
    var nextTexture: Texture {
        currentTexture = (currentTexture + 1) % textures.count
        return textures[currentTexture]
    }

    private var textures: [Texture] = []
    private var currentTexture = 0

    init(device: MTLDevice, width: Int, height: Int) {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(Constants.Metal.pixelFormat, width: width, height: height, mipmapped: false)
        for _ in 0..<Constants.numberOfInflightFrames {
            textures.append(Texture(texture: device.newTextureWithDescriptor(textureDescriptor)))
        }
    }
}
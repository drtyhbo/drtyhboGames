//
//  MultipassFilterRenderer.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/29/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class MultipassFilterRenderer: Renderer {
    func renderToCommandEncoder(commandBuffer: MTLCommandBuffer, inputTexture: MTLTexture) -> MTLTexture {
        fatalError("Subclasses must provide an implementation for this function.")
    }
}
//
//  SpriteInstance.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class SpriteInstance {
    weak var sprite: Sprite?

    var position: float2 = float2(0)
    var size: float2 = float2(0)
    var hidden: Bool = false

    var modelMatrix: Matrix4 {
        let matrix = Matrix4()
        matrix.translate(position[0], y: position[1], z: 0)
        matrix.scale(size[0], y: size[1], z: 1)
        return matrix
    }

    init(sprite: Sprite) {
        self.sprite = sprite
    }
}
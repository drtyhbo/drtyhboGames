//
//  Sprite.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Sprite {
    let size: float2
    private(set) var instances: [SpriteInstance] = []

    init(size: float2) {
        self.size = size
    }

    func createInstance() -> SpriteInstance {
        let spriteInstance = SpriteInstance(sprite: self)
        spriteInstance.size = size
        instances.append(spriteInstance)
        return spriteInstance
    }
}
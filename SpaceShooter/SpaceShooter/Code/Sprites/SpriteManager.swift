//
//  SpriteManager.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class SpriteManager {
    static let sharedManager = SpriteManager()

    private(set) var sprites: [Sprite] = []

    func createSpriteWithSize(size: float2) -> Sprite {
        let sprite = Sprite(size: size)
        sprites.append(sprite)
        return sprite
    }
}
//
//  Matrix4.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/20/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

extension Matrix4 {
    static func makeOrthoWithScreenSize() -> Matrix4 {
        let screenSize = UIScreen.mainScreen().bounds.size
        return Matrix4.makeOrthoLeft(0, right: Float(screenSize.width), bottom: Float(screenSize.height), top: 0, nearZ: -1, farZ: 1)
    }

    static func makeOrthoWithScreenSizeAndScale() -> Matrix4 {
        var screenSize = UIScreen.mainScreen().bounds.size
        screenSize.width *= UIScreen.mainScreen().scale
        screenSize.height *= UIScreen.mainScreen().scale
        return Matrix4.makeOrthoLeft(0, right: Float(screenSize.width), bottom: Float(screenSize.height), top: 0, nearZ: -1, farZ: 1)
    }

}
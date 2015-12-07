//
//  Label.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/13/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Label {
    enum Alignment {
        case Left
        case Right
        case Center
        case Top
        case Bottom
        case Middle
    }

    let position: float2
    let alignment: [Alignment]
    var text: String = ""
    var alpha: Float = 1
    var fontSize: Float = 20
    var color: float3 = float3(1, 1, 1)

    var textRendererData: AnyObject?

    init(position: float2, alignment: [Alignment]) {
        self.position = position
        self.alignment = alignment
    }
}
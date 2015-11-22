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
    }

    let position: float2
    let alignment: Alignment
    var text: String = ""

    var textRendererData: AnyObject?

    init(position: float2, alignment: Alignment) {
        self.position = position
        self.alignment = alignment
    }
}
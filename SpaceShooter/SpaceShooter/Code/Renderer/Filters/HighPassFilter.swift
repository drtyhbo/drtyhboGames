//
//  HighPassFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/22/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class HighPassFilter: FilterRenderer {
    init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        super.init(device: device, commandQueue: commandQueue, vertexFunction: "highPassFilterVertex", fragmentFunction: "highPassFilterFragment", alphaBlending: false)
    }
}
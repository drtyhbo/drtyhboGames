//
//  BloomFilter.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class BloomFilter: UnaryImageFilter {
    init(device: MTLDevice) {
        super.init(device: device, functionName: "bloom_shader")
    }
}
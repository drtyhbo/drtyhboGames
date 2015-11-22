//
//  Random.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/16/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Random {
    static func randomNumberBetween(lowerBound: Float, and upperBound: Float) -> Float {
        return Float(arc4random_uniform(10000)) / 10000 * (upperBound - lowerBound) + lowerBound
    }
}
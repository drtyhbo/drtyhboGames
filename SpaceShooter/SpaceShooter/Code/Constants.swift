//
//  Constants.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Constants {
    static let numberOfInflightFrames = 3

    struct Game {
        static let duration: Float = 180
    }

    struct Enemy {
        static let lightIntensity: Float = 20

        struct Die {
            static let gravityForce: Float = 100
            static let gravityRadius: Float = 10
            static let particleCount = 100
            static let particleSpeed: Float = 50
        }
    }

    struct Gem {
        static let color = float4(0.9176, 0.1529, 0.7608, 1)
        static let rotationSpeed = float3(2, 2, 2)
        static let scale: Float = 0.5
        static let lifespan: Float = 10
        static let fadeOutOver: Float = 2
    }

    struct Seeker {
        static let color = float4(0, 1, 0, 1)
        static let speed: Float = 15
    }

    struct Flyer {
        static let color = float4(1, 0.6, 0.2, 1)
        static let speed: Float = 15
    }

    struct Gravity {
        static let color = float4(1, 0.6, 0.2, 1)
        static let health: Float = 5
        static let gravityForce: Float = 75

        struct Damage {
            static let particleCount = 1000
            static let particleSpeed: Float = 75
        }

        struct Die {
            static let gravityForce: Float = -250
            static let gravityRadius: Float = 20
        }
    }

    struct Player {
        static let lightIntensity: Float = 50

        struct Spawn {
            static let spawnDuration: Float = 0.2
            static let gravityForce: Float = 300
            static let gravityRadius: Float = 30
            static let particleCount = 1000
            static let particleSpeed: Float = 150
        }

        struct Die {
            static let particleCount = 2000
            static let particleSpeed: Float = 150
        }
    }

    struct Particle {
        class TemporaryParticle {
            static let thickness: Float = 0.75
            static let maxAge: Float = 2
        }

        class LaserParticle {
            static let thickness: Float = 2.5
            static let length: Float = 2
            static let speed: Float = 75

            struct Explosion {
                static let particleCount = 30
                static let particleSpeed: Float = 10
            }
        }
    }

    struct World {
        static let spawnPadding: Float = 2
    }

    struct Metal {
        static let pixelFormat = MTLPixelFormat.BGRA8Unorm
    }

    struct UserDefaults {
        static let maxScoreKey = "MaxScore"
    }
}
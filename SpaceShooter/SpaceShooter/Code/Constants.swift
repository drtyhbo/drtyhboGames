//
//  Constants.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

func float3FromRed(red: Float, green: Float, blue: Float) -> float3 {
    return float3(red / 255, green / 255, blue / 255)
}

func float4FromRed(red: Float, green: Float, blue: Float) -> float4 {
    return float4(float3FromRed(red, green: green, blue: blue), 1)
}

class Constants {
    static let numberOfInflightFrames = 3

    struct Game {
        static let duration: Float = 180
    }

    struct Enemy {
        static let lightIntensity: Float = 5

        struct Die {
            static let gravityForce: Float = 300
            static let gravityRadius: Float = 10
            static let particleCount = 200
            static let particleSpeed: Float = 30
            static let lightDuration: Float = 0.5
            static let lightIntensity: Float = 50
        }
    }

    struct Gem {
        static let color = float4FromRed(177, green: 53, blue: 208)
        static let rotationSpeed = float3(2, 2, 2)
        static let scale: Float = 0.5
        static let lifespan: Float = 10
        static let fadeOutOver: Float = 2
    }

    struct Cube {
        static let color = float4FromRed(246, green: 0, blue: 84)
        static let speed: Float = 20
    }

    struct Seeker {
        static let color = float4FromRed(192, green: 184, blue: 27)
        static let speed: Float = 20
    }

    struct Flyer {
        static let color = float4FromRed(4, green: 202, blue: 254)
        static let speed: Float = 20
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
            static let gravityForce: Float = 400
            static let gravityRadius: Float = 20
            static let particleCount = 1000
            static let particleSpeed: Float = 75
            static let lightDuration: Float = 1
            static let lightIntensity: Float = 100
        }

        struct Die {
            static let particleCount = 2000
            static let particleSpeed: Float = 75
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
                static let particleSpeed: Float = 5
            }
        }
    }

    struct Scene {
        static let maxLights = 200
    }

    struct UI {
        static let gamePauseHelperTime: Float = 1
        static let newHighScoreLabelColor = float3FromRed(4, green: 202, blue: 254)
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
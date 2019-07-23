//
//  Vertex.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/4/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

extension Float {
    func degreesToRadians() -> Float {
        return Float(M_PI / 180) * self
    }
}

extension float3 {
    init(_ xy: float2, _ z: Float) {
        self.init(x: xy.x, y: xy.y, z: z)
    }

    init(_ xyzw: float4) {
        self.init(x: xyzw.x, y: xyzw.y, z: xyzw.z)
    }

    func rotateAroundY(radians: Float) -> float3 {
        let newX = x * cos(radians) - y * sin(radians)
        let newY = x * sin(radians) + y * cos(radians)
        let newZ = z
        return float3(newX, newY, newZ)
    }
}

func min(first: float3, _ second: float3) -> float3 {
    return float3(min(first[0], second[0]), min(first[1], second[1]), min(first[2], second[2]))
}

func max(first: float3, _ second: float3) -> float3 {
    return float3(max(first[0], second[0]), max(first[1], second[1]), max(first[2], second[2]))
}

extension float4 {
    static let size = MemoryLayout<Float>.size * 4

    init(_ xyz: float3, _ w: Float) {
        self.init(x: xyz.x, y: xyz.y, z: xyz.z, w: w)
    }

    func raw() -> [Float] {
        return [x, y, z, w]
    }
}

struct Vertex {
    static let size = MemoryLayout<Float>.size * 6

    var position: float3
    var normal: float3

    var floatBuffer: [Float] {
        return [position.x, position.y, position.z, normal.x, normal.y, normal.z]
    }

    static func vertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
      vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[0].offset = 0

      vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[1].offset = 3 * MemoryLayout<Float>.size

        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 6
      vertexDescriptor.layouts[0].stepFunction = .perVertex

        return vertexDescriptor
    }

    init(position: float3, normal: float3) {
        self.position = position
        self.normal = normal
    }
}

struct PerInstanceUniforms {
    static let size = Matrix4.size() * 2 + float4.size

    let modelViewMatrix: Matrix4
    let normalMatrix: Matrix4
    let color: float4
}

struct Size {
    var width: Float
    var height: Float

    init(size: CGSize) {
        width = Float(size.width)
        height = Float(size.height)
    }
}

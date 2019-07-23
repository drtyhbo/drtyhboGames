//
//  ModelLoader.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/4/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation
import Metal

class Model {
    let vertices: [Vertex]
    let indices: [UInt16]
    let vertexData: [Float]

    init(vertices: [Vertex], indices: [UInt16]) {
        self.vertices = vertices
        self.indices = indices

        var vertexData: [Float] = []
        for vertex in vertices {
            vertexData += vertex.floatBuffer
        }
        self.vertexData = vertexData
    }
}

class ModelLoader {
    static let sharedLoader = ModelLoader()

    private let commentRegex = "^\\s*#".toRx()
    private let vertexRegex = "^v ".toRx()
    private let vertexNormalRegex = "^vn ".toRx()
    private let faceRegex = "^f ".toRx()
    private let whitespaceRegex = " ".toRx()

    private var modelCache: [String:Model] = [:]

    func loadWithName(name: String) -> Model? {
        if let model = modelCache[name] {
            return model
        }

        do {
          if let filePath = Bundle.main.path(forResource: name, ofType: "obj") {
                let objFile = try String(contentsOfFile: filePath)
            if let model = parseObjFile(objFile: objFile) {
                    modelCache[name] = model
                    return model
                }
            }
        } catch {
        }

        return nil
    }

    private func vertexFromVertexLine(line: String) -> float3 {
        let pieces = line.split(whitespaceRegex)
      return float3((pieces![1] as AnyObject).floatValue!, (pieces![2] as AnyObject).floatValue!, (pieces![3] as AnyObject).floatValue!)
    }

    private func normalFromVertexNormalLine(line: String) -> float3 {
        let pieces = line.split(whitespaceRegex)
      return float3((pieces![1] as AnyObject).floatValue!, (pieces![2] as AnyObject).floatValue!, (pieces![3] as AnyObject).floatValue!)
    }

    private func convertFromFileVertices(fileVertices: [float3], fileNormals: [float3], faceTriplets: [String]) -> ([Vertex], [UInt16]) {
        var vertices: [Vertex] = []
        var indices: [UInt16] = []
        var indexLookup: [String:UInt16] = [:]

        for faceTriplet in faceTriplets {
            if let index = indexLookup[faceTriplet] {
                indices.append(index)
            } else {
                let index = UInt16(vertices.count)
                indexLookup[faceTriplet] = index
              vertices.append(vertexFromFaceTriplet(triplet: faceTriplet, vertices: fileVertices, normals: fileNormals))
                indices.append(index)
            }
        }

        return (vertices, indices)
    }

    private func vertexFromFaceTriplet(triplet: String, vertices: [float3], normals: [float3]) -> Vertex {
      let pieces = triplet.components(separatedBy: "/").map({ Int(($0 as NSString).intValue) })
        let vertex = Vertex(position: vertices[pieces[0] - 1], normal: normals[pieces[2] - 1])
        return vertex
    }

    private func parseObjFile(objFile: String) -> Model? {
        var fileVertices: [float3] = []
        var fileNormals: [float3] = []
        var faceTriplets: [String] = []
      var minVertex: float3 = float3(repeating: FLT_MAX)
      var maxVertex: float3 = float3(repeating: FLT_MIN)
      for line in objFile.components(separatedBy: "\n") {
            if line.isMatch(commentRegex) {
                continue
            }

            if line.isMatch(vertexRegex) {
              let vertex = vertexFromVertexLine(line: line)
                minVertex = min(minVertex, vertex)
                maxVertex = max(maxVertex, vertex)
                fileVertices.append(vertex)
            } else if line.isMatch(vertexNormalRegex) {
              fileNormals.append(normalFromVertexNormalLine(line: line))
            } else if line.isMatch(faceRegex) {
                let pieces = line.split(whitespaceRegex)

                var faceIndices: [String] = []
              for index in 1..<pieces!.count {
                faceIndices.append(pieces![index] as! String)
                }

              for index in 1..<pieces!.count - 2 {
                    faceTriplets += [faceIndices[0], faceIndices[index], faceIndices[index + 1]]
                }
            }
        }

        for i in 0..<fileVertices.count {
            fileVertices[i][0] -= minVertex[0] + (maxVertex[0] - minVertex[0]) / 2
            fileVertices[i][1] -= minVertex[1] + (maxVertex[1] - minVertex[1]) / 2
            fileVertices[i][2] -= minVertex[2] + (maxVertex[2] - minVertex[2]) / 2
        }

      let (vertices, indices) = convertFromFileVertices(fileVertices: fileVertices, fileNormals: fileNormals, faceTriplets: faceTriplets)

        return Model(vertices: vertices, indices: indices)
    }
}

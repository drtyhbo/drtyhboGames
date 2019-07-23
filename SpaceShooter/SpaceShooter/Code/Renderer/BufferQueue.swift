//
//  BufferQueue.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/5/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

class Buffer {
    let buffer: MTLBuffer
    private(set) var currentOffset = 0

    init(buffer: MTLBuffer) {
        self.buffer = buffer
    }

    func copyData(data: UnsafeRawPointer, size: Int) {
        if currentOffset + size > buffer.length {
            fatalError("copyData exceeds buffer length.")
        }

        memcpy(buffer.contents() + currentOffset, data, size)
        currentOffset += size
    }

    func reset() {
        currentOffset = 0
    }
}

class BufferQueue {
    var nextBuffer: Buffer {
        currentBuffer = (currentBuffer + 1) % buffers.count

        let buffer = buffers[currentBuffer]
        buffer.reset()
        return buffer
    }

    private var buffers: [Buffer] = []
    private var currentBuffer = 0

    init(device: MTLDevice, length: Int) {
        for _ in 0..<Constants.numberOfInflightFrames {
          buffers.append(Buffer(buffer: device.makeBuffer(length: length, options: MTLResourceOptions(rawValue: 0))!))
        }
    }
}

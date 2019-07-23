//
//  UIImage.swift
//  SpaceShooter
//
//  Created by Andreas Binnewies on 11/21/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Foundation

extension UIImage {
    static func circleWithRadius(radius: CGFloat, lineWidth: CGFloat, color: UIColor) -> UIImage {
      UIGraphicsBeginImageContextWithOptions(CGSize(width: radius * 2, height: radius * 2), false, 0)

        let context = UIGraphicsGetCurrentContext()
      context!.setLineWidth(lineWidth)
      context!.setStrokeColor(color.cgColor)
      context?.strokeEllipse(in: CGRect(x: lineWidth, y: lineWidth, width: radius * 2 - lineWidth * 2, height: radius * 2 - lineWidth * 2))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

      return image!
    }

    static func MTLTextureToUIImage(texture: MTLTexture) -> UIImage {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * texture.width
      var imageBytes = [UInt8](_unsafeUninitializedCapacity: texture.width * texture.height * bytesPerPixel, initializingWith: {_,_ in})
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
      texture.getBytes(&imageBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

      let providerRef = CGDataProvider(data: NSData(bytes: &imageBytes, length: imageBytes.count * MemoryLayout<UInt8>.size))
      let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)

      let imageRef = CGImage(width: texture.width, height: texture.height, bitsPerComponent: 8, bitsPerPixel: bytesPerPixel * 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, provider: providerRef!, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
      
      return UIImage(cgImage: imageRef!)
    }

    func createMTLTextureForDevice(device: MTLDevice) -> MTLTexture {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = self.cgImage!.width
        let height = self.cgImage!.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let rowBytes = width * 4

      let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
      context!.clear(bounds)
      context?.draw(self.cgImage!, in: bounds)

      let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm, width: width, height: height, mipmapped: false)
      let texture = device.makeTexture(descriptor: textureDescriptor)

      texture!.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: (context?.data)!, bytesPerRow: rowBytes)

      return texture!
    }
}

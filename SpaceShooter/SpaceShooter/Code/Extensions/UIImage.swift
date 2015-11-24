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
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(radius * 2, radius * 2), false, 0)

        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, color.CGColor)
        CGContextStrokeEllipseInRect(context, CGRectMake(lineWidth, lineWidth, radius * 2 - lineWidth * 2, radius * 2 - lineWidth * 2))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    static func MTLTextureToUIImage(texture: MTLTexture) -> UIImage {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * texture.width
        var imageBytes = [UInt8](count: texture.width * texture.height * bytesPerPixel, repeatedValue: 0)
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(&imageBytes, bytesPerRow: bytesPerRow, fromRegion: region, mipmapLevel: 0)

        let providerRef = CGDataProviderCreateWithCFData(NSData(bytes: &imageBytes, length: imageBytes.count * sizeof(UInt8)))
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.ByteOrder32Big.rawValue | CGImageAlphaInfo.PremultipliedLast.rawValue)
        let imageRef = CGImageCreate(texture.width, texture.height, 8, bytesPerPixel * 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), bitmapInfo, providerRef, nil, false, .RenderingIntentDefault)!

        return UIImage(CGImage: imageRef)
    }

    func createMTLTextureForDevice(device: MTLDevice) -> MTLTexture {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let width = CGImageGetWidth(CGImage)
        let height = CGImageGetHeight(CGImage)
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let rowBytes = width * 4

        let context = CGBitmapContextCreate(nil, width, height, 8, rowBytes, colorSpace, CGImageAlphaInfo.PremultipliedLast.rawValue)
        CGContextClearRect(context, bounds)
        CGContextDrawImage(context, bounds, CGImage)

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(MTLPixelFormat.RGBA8Unorm, width: width, height: height, mipmapped: false)
        let texture = device.newTextureWithDescriptor(textureDescriptor)

        texture.replaceRegion(MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: CGBitmapContextGetData(context), bytesPerRow: rowBytes)

        return texture
    }
}
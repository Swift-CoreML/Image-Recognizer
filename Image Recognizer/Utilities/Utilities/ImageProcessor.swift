//
//  File.swift
//  BasicCoreML
//
//  Created by Brian Advent on 09.06.17.
//  Copyright © 2017 Brian Advent. All rights reserved.
//
import UIKit
import CoreVideo

struct ImageProcessor {
    static func pixelBuffer (forImage image:CGImage) -> CVPixelBuffer? {
        
        
        let frameSize = CGSize(width: image.width, height: image.height)
        
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
            
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
        
    }
    
    static func resizeImage(_ image:UIImage?) -> UIImage?{
        // Resize
        let newWidth:CGFloat = 299.0
        let newHeight:CGFloat = 299.0
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        image?.draw(in:CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let finalImage = newImage else {
            fatalError("Unexpected runtime error.")
        }
        
        return finalImage
    }
    
}

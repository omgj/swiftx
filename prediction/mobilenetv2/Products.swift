//
//  Products.swift
//  catpredict
//
//  Created by me on 10/1/22.
//

import Foundation
import CoreML
import UIKit

struct Guess {
    var name: String
    var prob: Double
}

class prodpred {
    let model = try? MobileNetV2(configuration: MLModelConfiguration())

    
    func predict(image: UIImage) -> [String] {
        let ri = image.resizeImageTo(size: CGSize(width: 224, height: 224))
        let b = ri?.convertToBuffer()
        let output = try? model?.prediction(image: b!)
        let l = output?.classLabelProbs ?? [:]
        var uu: [Guess] = []
        for (ii, qq) in l {
            uu.append(Guess(name: ii, prob: qq))
        }
        uu.sort{ $0.prob > $1.prob }
        var ret: [String] = []
        for ee in uu {
            let rr = ee.name.split(separator: ",")
            for dd in rr {
                if ret.count == 10 {
                    return ret
                }
                ret.append(String(dd))
            }
        }
        return ret
    }
}

extension UIImage {

    func resizeImageTo(size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }

     func convertToBuffer() -> CVPixelBuffer? {

        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, Int(self.size.width),
            Int(self.size.height),
            kCVPixelFormatType_32ARGB,
            attributes,
            &pixelBuffer)

        guard (status == kCVReturnSuccess) else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        let context = CGContext(
            data: pixelData,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer
    }

}

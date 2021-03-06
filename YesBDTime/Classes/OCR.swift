import Vision
import CoreGraphics

internal func ocr(image: NSImage, callback: @escaping (TimeInterval) -> (), debugCallback: ((NSImage, [(NSRect, NSImage, Int64)]) -> Void)? = nil) {
    let textReq = VNDetectTextRectanglesRequest { req, error in
        guard let observations = req.results as? [VNTextObservation] else { return }
        let characterBoxes = observations.flatMap {$0.characterBoxes ?? []}
        //            NSLog("%@", "\(characterBoxes)")
        let sourceImage = image

        do {
            let results = try characterBoxes
                .filter {abs($0.topLeft.y - $0.bottomRight.y) > 0.5}
                .map { box -> (CGRect, NSImage, Int64) in
                    let size = CGSize(width: abs(box.bottomRight.x - box.topLeft.x) * sourceImage.size.width,
                                      height: abs(box.bottomRight.y - box.topLeft.y) * sourceImage.size.height)
                    let image = NSImage(size: CGSize(width: 28, height: 28))
                    image.lockFocus()
                    NSColor.black.set()
                    CGRect(origin: .zero, size: image.size).fill()
                    sourceImage.draw(at: CGPoint(x: (28 - size.width) / 2, y: (28 - size.height) / 2), from: CGRect(
                        x: min(box.bottomRight.x, box.topLeft.x) * sourceImage.size.width,
                        y: min(box.bottomRight.y, box.topLeft.y) * sourceImage.size.height,
                        width: size.width,
                        height: size.height), operation: .copy, fraction: 1)
                    image.unlockFocus()

                    let pixelBuffer = image.pixelBuffer(width: 227, height: 227)!
//                    let ciImage = CIImage(cvImageBuffer: pixelBuffer)
//                    let nsImage = NSImage(cgImage: CIContext().createCGImage(ciImage, from: ciImage.extent)!, size: CGSize(width: 227, height: 227))
                    let prediction = try BDDigitsClassifier().prediction(input: BDDigitsClassifierInput(image: pixelBuffer))
                    //                        NSLog("%@", "\(prediction.classLabel)   \(prediction.prediction[prediction.classLabel])")
                    return (CGRect(x: box.topLeft.x,
                                   y: box.topLeft.y,
                                   width: abs(box.bottomRight.x - box.topLeft.x),
                                   height: abs(box.bottomRight.y - box.topLeft.y))
                        .applying(CGAffineTransform(scaleX: sourceImage.size.width, y: sourceImage.size.height)),
                            image,
                            Int64(prediction.label)!)
            }

            let prefixedReversedDigits = Array(([0] + results.map {$0.2}).reversed())
            let components = stride(from: 0, to: prefixedReversedDigits.count - 1, by: 2)
                .map {(prefixedReversedDigits[$0 + 1], prefixedReversedDigits[$0])}.reversed()
            //                let positionString: String = components.map {"\($0)\($1)"}.joined(separator: ":")
            //                NSLog("%@", positionString)
            let numberComponents = components.map {10 * $0 + $1}
            let seconds = numberComponents.reversed().enumerated()
                .map {n, x in pow(60, Double(n)) * Double(x)}
                .reduce(0, +)
            callback(seconds)
            debugCallback?(image, results)
        } catch _ {}
    }
    textReq.reportCharacterBoxes = true
    guard let cgImage = (image.representations[0] as! NSBitmapImageRep).cgImage else { return }
    _ = try? VNImageRequestHandler(cgImage: cgImage).perform([textReq])
}

// https://gist.github.com/DennisWeidmann/7c4b4bb72062bd1a40c714aa5d95a0d7
extension NSImage {
    func pixelBuffer(width: CGFloat, height: CGFloat) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(width),
                                         Int(height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)

        guard let resultPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }

        CVPixelBufferLockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(resultPixelBuffer)

        let colorspace = NSColorSpace.genericRGB.cgColorSpace!
        guard let context = CGContext(data: pixelData,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(resultPixelBuffer),
                                      space: colorspace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {return nil}

//                context.translateBy(x: 0, y: CGFloat(height))
//                context.scaleBy(x: 1.0, y: -1.0)

        let graphicsContext = NSGraphicsContext(cgContext: context, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        graphicsContext.imageInterpolation = .none
        NSGraphicsContext.current = graphicsContext
        draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        NSGraphicsContext.restoreGraphicsState()

        CVPixelBufferUnlockBaseAddress(resultPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

        return resultPixelBuffer
    }
}

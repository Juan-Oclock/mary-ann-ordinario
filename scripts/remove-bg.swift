import Vision
import CoreImage
import Foundation

// Usage: swift remove-bg.swift <input> <output>
// Uses Apple's Vision subject-segmentation (same engine as Finder's
// "Remove Background" quick action) to produce a transparent-PNG cutout.

let args = CommandLine.arguments
guard args.count == 3 else {
    FileHandle.standardError.write("usage: remove-bg <input> <output>\n".data(using: .utf8)!)
    exit(1)
}

guard let input = CIImage(contentsOf: URL(fileURLWithPath: args[1])) else {
    FileHandle.standardError.write("cannot load input image\n".data(using: .utf8)!)
    exit(1)
}

let request = VNGenerateForegroundInstanceMaskRequest()
let handler = VNImageRequestHandler(ciImage: input)

do {
    try handler.perform([request])
    guard let result = request.results?.first else {
        FileHandle.standardError.write("no foreground subject detected\n".data(using: .utf8)!)
        exit(2)
    }
    let maskBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
    let mask = CIImage(cvPixelBuffer: maskBuffer)

    let blend = CIFilter(name: "CIBlendWithMask")!
    blend.setValue(input, forKey: kCIInputImageKey)
    blend.setValue(CIImage(color: .clear).cropped(to: input.extent), forKey: kCIInputBackgroundImageKey)
    blend.setValue(mask, forKey: kCIInputMaskImageKey)

    let context = CIContext()
    try context.writePNGRepresentation(
        of: blend.outputImage!,
        to: URL(fileURLWithPath: args[2]),
        format: .RGBA8,
        colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!
    )
    print("wrote \(args[2])")
} catch {
    FileHandle.standardError.write("error: \(error)\n".data(using: .utf8)!)
    exit(3)
}

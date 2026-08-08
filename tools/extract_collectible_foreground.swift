import CoreImage
import Foundation
import ImageIO
import UniformTypeIdentifiers
import Vision

private enum ToolError: LocalizedError {
  case usage
  case unreadableInput
  case missingImage
  case missingMask
  case writeFailed

  var errorDescription: String? {
    switch self {
    case .usage:
      "Usage: extract_collectible_foreground <input> <output> [max-dimension]"
    case .unreadableInput:
      "The input image could not be read."
    case .missingImage:
      "The input does not contain a raster image."
    case .missingMask:
      "Vision could not isolate a foreground object."
    case .writeFailed:
      "The transparent PNG could not be written."
    }
  }
}

func extractForeground() throws {
  guard CommandLine.arguments.count >= 3 else { throw ToolError.usage }

  let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
  let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
  let maxDimension = CommandLine.arguments.count > 3
    ? CGFloat(Int(CommandLine.arguments[3]) ?? 768)
    : 768

  guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
    throw ToolError.unreadableInput
  }
  guard let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    throw ToolError.missingImage
  }

  let request = VNGenerateForegroundInstanceMaskRequest()
  let handler = VNImageRequestHandler(cgImage: image)
  try handler.perform([request])

  guard let observation = request.results?.first,
        !observation.allInstances.isEmpty else {
    throw ToolError.missingMask
  }

  let maskBuffer = try observation.generateScaledMaskForImage(
    forInstances: observation.allInstances,
    from: handler
  )

  let sourceImage = CIImage(cgImage: image)
  let clearImage = CIImage(color: .clear).cropped(to: sourceImage.extent)
  let maskImage = CIImage(cvPixelBuffer: maskBuffer)
  let composited = sourceImage.applyingFilter(
    "CIBlendWithMask",
    parameters: [
      kCIInputBackgroundImageKey: clearImage,
      kCIInputMaskImageKey: maskImage
    ]
  )

  let largestDimension = max(composited.extent.width, composited.extent.height)
  let scale = min(1, maxDimension / largestDimension)
  let resized = composited
    .transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    .applyingFilter("CILanczosScaleTransform", parameters: [
      kCIInputScaleKey: 1,
      kCIInputAspectRatioKey: 1
    ])

  let context = CIContext(options: [.cacheIntermediates: false])
  let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
  try FileManager.default.createDirectory(
    at: outputURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  try context.writePNGRepresentation(
    of: resized,
    to: outputURL,
    format: .RGBA8,
    colorSpace: colorSpace
  )

  guard FileManager.default.fileExists(atPath: outputURL.path) else {
    throw ToolError.writeFailed
  }
}

do {
  try extractForeground()
} catch {
  FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
  exit(1)
}

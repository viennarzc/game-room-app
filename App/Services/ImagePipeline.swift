import Foundation
import ImageIO
import UniformTypeIdentifiers

enum ImagePipeline {
  static func downsizedJPEG(
    from data: Data,
    maxPixelSize: Int = 1_600,
    compressionQuality: Double = 0.82
  ) -> Data? {
    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

    let options: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
    ]

    guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary),
          let output = CFDataCreateMutable(nil, 0),
          let destination = CGImageDestinationCreateWithData(
            output,
            UTType.jpeg.identifier as CFString,
            1,
            nil
          ) else { return nil }

    CGImageDestinationAddImage(
      destination,
      image,
      [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
    )

    guard CGImageDestinationFinalize(destination) else { return nil }
    return output as Data
  }
}

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct StoredImageView: View {
  let data: Data
  var contentMode: ContentMode = .fit

  var body: some View {
    if let image = platformImage {
      image
        .resizable()
        .aspectRatio(contentMode: contentMode)
    } else {
      ContentUnavailableView("Photo unavailable", systemImage: "photo.badge.exclamationmark")
    }
  }

  private var platformImage: Image? {
    #if canImport(UIKit)
    guard let image = UIImage(data: data) else { return nil }
    return Image(uiImage: image)
    #elseif canImport(AppKit)
    guard let image = NSImage(data: data) else { return nil }
    return Image(nsImage: image)
    #else
    return nil
    #endif
  }
}

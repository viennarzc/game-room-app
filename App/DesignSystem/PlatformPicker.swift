import SwiftUI

struct GamePlatformPicker: View {
  let title: LocalizedStringKey
  @Binding var selection: GamingPlatform

  init(_ title: LocalizedStringKey = "Platform", selection: Binding<GamingPlatform>) {
    self.title = title
    _selection = selection
  }

  var body: some View {
    Picker(selection: $selection) {
      ForEach(GamingPlatform.allCases) { platform in
        Label(platform.rawValue, systemImage: platform.pickerSymbolName)
          .tag(platform)
      }
    } label: {
      HStack(spacing: 10) {
        PlatformAssetThumbnail(platform: selection)
        Text(title)
      }
    }
  }
}

struct FavoritePlatformPicker: View {
  @Binding var selection: GamingPlatform?

  var body: some View {
    Picker(selection: $selection) {
      Text("Not set").tag(GamingPlatform?.none)
      ForEach(GamingPlatform.allCases) { platform in
        Label(platform.rawValue, systemImage: platform.pickerSymbolName)
          .tag(Optional(platform))
      }
    } label: {
      HStack(spacing: 10) {
        PlatformAssetThumbnail(platform: selection)
        Text("Favorite")
      }
    }
  }
}

extension GamingPlatform {
  var pickerSymbolName: String {
    switch self {
    case .pc, .mac, .handheldPC:
      "desktopcomputer"
    case .mobile:
      "iphone"
    case .virtualReality:
      "vision.pro"
    case .other:
      "questionmark.square.dashed"
    default:
      "gamecontroller.fill"
    }
  }
}

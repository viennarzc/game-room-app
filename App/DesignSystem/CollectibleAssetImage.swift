import SwiftUI

/// Renders a downloadable collectible and retains a purposeful native fallback
/// while its Background Assets pack is unavailable.
struct CollectibleAssetImage: View {
  @Environment(\.appTheme) private var theme

  let asset: CollectibleAssetID
  var fallbackSymbol: String
  var contentMode: ContentMode = .fit
  var downloadIfNeeded = true
  var isDecorative = false

  @State private var imageData: Data?
  @State private var isLoading = false

  var body: some View {
    ZStack {
      if let imageData {
        StoredImageView(data: imageData, contentMode: contentMode)
      } else {
        Image(systemName: fallbackSymbol)
          .font(.title2.weight(.medium))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(theme.color(.secondaryAccent))

        if isLoading {
          ProgressView()
            .controlSize(.small)
        }
      }
    }
    .task(id: "\(asset.rawValue)-\(downloadIfNeeded)") {
      isLoading = true
      imageData = await CollectibleAssetRepository.shared.imageData(
        for: asset,
        downloadIfNeeded: downloadIfNeeded
      )
      isLoading = false
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(asset.displayName)
    .accessibilityHidden(isDecorative)
  }
}

struct PlatformAssetThumbnail: View {
  @Environment(\.appTheme) private var theme

  let platform: GamingPlatform?
  var size: CGFloat = 36
  var downloadIfNeeded = true

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
        .fill(theme.color(.elevatedSurface))

      if let asset = platform?.collectibleAsset {
        CollectibleAssetImage(
          asset: asset,
          fallbackSymbol: platform?.pickerSymbolName ?? "gamecontroller.fill",
          downloadIfNeeded: downloadIfNeeded,
          isDecorative: true
        )
        .padding(size * 0.12)
      } else {
        Image(systemName: platform?.pickerSymbolName ?? "questionmark.square.dashed")
          .font(.subheadline.weight(.semibold))
          .foregroundStyle(theme.color(.textSecondary))
          .accessibilityHidden(true)
      }
    }
    .frame(width: size, height: size)
    .overlay {
      RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
        .stroke(theme.color(.divider), lineWidth: 1)
    }
    .accessibilityHidden(true)
  }
}

struct CollectibleHeroCard: View {
  @Environment(\.appTheme) private var theme

  let asset: CollectibleAssetID
  let title: LocalizedStringResource
  let description: LocalizedStringResource
  var downloadIfNeeded = true

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HeroContent(
        asset: asset,
        title: title,
        description: description,
        downloadIfNeeded: downloadIfNeeded,
        isHorizontal: true
      )
      HeroContent(
        asset: asset,
        title: title,
        description: description,
        downloadIfNeeded: downloadIfNeeded,
        isHorizontal: false
      )
    }
    .padding(20)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .stroke(theme.color(.divider), lineWidth: 1)
    }
  }
}

private struct HeroContent: View {
  @Environment(\.appTheme) private var theme

  let asset: CollectibleAssetID
  let title: LocalizedStringResource
  let description: LocalizedStringResource
  let downloadIfNeeded: Bool
  let isHorizontal: Bool

  init(
    asset: CollectibleAssetID,
    title: LocalizedStringResource,
    description: LocalizedStringResource,
    downloadIfNeeded: Bool,
    isHorizontal: Bool
  ) {
    self.asset = asset
    self.title = title
    self.description = description
    self.downloadIfNeeded = downloadIfNeeded
    self.isHorizontal = isHorizontal
  }

  var body: some View {
    Group {
      if isHorizontal {
        HStack(spacing: 20) {
          illustration
          copy
        }
      } else {
        VStack(alignment: .leading, spacing: 16) {
          illustration
          copy
        }
      }
    }
  }

  private var illustration: some View {
    CollectibleAssetImage(
      asset: asset,
      fallbackSymbol: asset.pack.symbolName,
      downloadIfNeeded: downloadIfNeeded,
      isDecorative: true
    )
    .frame(width: isHorizontal ? 144 : 180, height: isHorizontal ? 128 : 152)
    .background(theme.color(.elevatedSurface), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }

  private var copy: some View {
    VStack(alignment: .leading, spacing: 7) {
      Text(title)
        .font(.title3.weight(.semibold))
      Text(description)
        .font(.subheadline)
        .foregroundStyle(theme.color(.textSecondary))
        .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

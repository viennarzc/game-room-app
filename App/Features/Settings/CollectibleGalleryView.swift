import SwiftUI

struct CollectibleGalleryView: View {
  @Environment(\.appTheme) private var theme

  var body: some View {
    List {
      Section {
        Label("Artwork stays ready", systemImage: "photo.stack")
          .font(.headline)
        Text("Game Room includes compact pastel artwork for every collection. On newer systems, managed packs can refresh it without an app update.")
          .font(.footnote)
          .foregroundStyle(theme.color(.textSecondary))
      }

      Section("Collections") {
        ForEach(CollectibleAssetPack.allCases) { pack in
          NavigationLink {
            CollectiblePackGalleryView(pack: pack)
          } label: {
            CollectiblePackRow(pack: pack)
          }
        }
      }
    }
    .scrollContentBackground(.hidden)
    .background(theme.color(.canvas))
    .navigationTitle("Collectible Gallery")
  }
}

private struct CollectiblePackRow: View {
  @Environment(\.appTheme) private var theme

  let pack: CollectibleAssetPack

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: pack.symbolName)
        .font(.title3)
        .foregroundStyle(theme.color(.accent))
        .frame(width: 30, height: 30)
        .background(theme.color(.elevatedSurface), in: RoundedRectangle(cornerRadius: 9, style: .continuous))

      VStack(alignment: .leading, spacing: 3) {
        Text(pack.name)
          .font(.body.weight(.medium))
        Text(pack.summary)
          .font(.caption)
          .foregroundStyle(theme.color(.textSecondary))
          .lineLimit(1)
      }

      Spacer(minLength: 8)

      Text("\(pack.assets.count)")
        .font(.caption.weight(.semibold))
        .foregroundStyle(theme.color(.textSecondary))
    }
    .accessibilityElement(children: .combine)
  }
}

private struct CollectiblePackGalleryView: View {
  @Environment(\.appTheme) private var theme

  let pack: CollectibleAssetPack

  @State private var phase: PackPhase = .loading
  @State private var retryCount = 0

  private let columns = [GridItem(.adaptive(minimum: 126, maximum: 180), spacing: 14)]

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        CollectibleHeroCard(
          asset: pack.assets.first ?? .controllerLate2010sSymmetric,
          title: pack.name,
          description: pack.summary,
          downloadIfNeeded: false
        )
        .id(phase)

        switch phase {
        case .loading:
          ProgressView("Preparing artwork")
            .frame(maxWidth: .infinity, minHeight: 220)
        case .available:
          LazyVGrid(columns: columns, spacing: 14) {
            ForEach(pack.assets) { asset in
              CollectibleGalleryItem(asset: asset)
            }
          }
        case .unavailable:
          ContentUnavailableView {
            Label("Artwork unavailable", systemImage: "icloud.slash")
          } description: {
            Text("Check your connection, then try the collection again. The rest of Game Room remains available offline.")
          } actions: {
            Button("Try Again", systemImage: "arrow.clockwise") {
              retryCount += 1
            }
            .buttonStyle(.borderedProminent)
          }
          .frame(maxWidth: .infinity, minHeight: 220)
        }
      }
      .padding(20)
      .frame(maxWidth: 980)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .background(theme.color(.canvas))
    .navigationTitle(String(localized: pack.name))
    .task(id: retryCount) {
      phase = .loading
      do {
        try await CollectibleAssetRepository.shared.prefetch(pack)
        phase = .available
      } catch {
        phase = .unavailable
      }
    }
  }
}

private struct CollectibleGalleryItem: View {
  @Environment(\.appTheme) private var theme

  let asset: CollectibleAssetID

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      CollectibleAssetImage(
        asset: asset,
        fallbackSymbol: asset.pack.symbolName,
        downloadIfNeeded: false,
        isDecorative: true
      )
      .frame(maxWidth: .infinity)
      .frame(height: 106)
      .background(theme.color(.elevatedSurface), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

      Text(asset.displayName)
        .font(.caption.weight(.medium))
        .foregroundStyle(theme.color(.textPrimary))
        .lineLimit(2)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(12)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 18, style: .continuous)
        .stroke(theme.color(.divider), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

private enum PackPhase: Hashable {
  case loading
  case available
  case unavailable
}

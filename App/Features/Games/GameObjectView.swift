import SwiftUI

struct GameObjectView: View {
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  var body: some View {
    GeometryReader { proxy in
      GameObjectArtwork(
        title: game.title,
        platform: game.platform,
        style: game.objectStyle,
        coverImageData: game.coverImageData,
        size: proxy.size
      )
    }
    .shadow(color: .black.opacity(0.18), radius: 7, x: 3, y: 6)
    .accessibilityLabel("\(game.title), \(game.platformDisplayName)")
  }
}

struct GameObjectPreview: View {
  let title: String
  let platform: GamingPlatform
  let style: GameObjectStyle
  let coverImageData: Data?

  var body: some View {
    GeometryReader { proxy in
      GameObjectArtwork(
        title: title,
        platform: platform,
        style: style,
        coverImageData: coverImageData,
        size: proxy.size
      )
    }
    .shadow(color: .black.opacity(0.18), radius: 7, x: 3, y: 6)
    .accessibilityHidden(true)
  }
}

private struct GameObjectArtwork: View {
  @Environment(\.appTheme) private var theme
  let title: String
  let platform: GamingPlatform
  let style: GameObjectStyle
  let coverImageData: Data?
  let size: CGSize

  var body: some View {
    switch style {
    case .cartridge:
      cartridge
    case .digitalCard:
      digitalCard
    case .slimCase, .tallCase, .collectorCard:
      gameCase
    }
  }

  private var gameCase: some View {
    ZStack(alignment: .leading) {
      RoundedRectangle(cornerRadius: max(8, size.width * 0.09))
        .fill(platform.systemColor.gradient)
      Rectangle()
        .fill(.black.opacity(0.16))
        .frame(width: max(6, size.width * 0.1))
        .padding(.vertical, size.width * 0.06)
      coverPanel
        .padding(.leading, size.width * 0.16)
        .padding(.trailing, size.width * 0.07)
        .padding(.vertical, size.width * 0.11)
    }
    .overlay {
      RoundedRectangle(cornerRadius: max(8, size.width * 0.09))
        .stroke(.white.opacity(0.28), lineWidth: 1)
    }
    .rotation3DEffect(.degrees(-4), axis: (x: 0, y: 1, z: 0))
  }

  private var cartridge: some View {
    VStack(spacing: 0) {
      ZStack {
        UnevenRoundedRectangle(
          topLeadingRadius: size.width * 0.14,
          bottomLeadingRadius: size.width * 0.04,
          bottomTrailingRadius: size.width * 0.04,
          topTrailingRadius: size.width * 0.14
        )
        .fill(platform.systemColor.gradient)
        coverPanel
          .padding(.horizontal, size.width * 0.12)
          .padding(.top, size.width * 0.2)
          .padding(.bottom, size.width * 0.1)
      }
      HStack(spacing: 2) {
        ForEach(0..<8, id: \.self) { _ in
          Rectangle().fill(.yellow.opacity(0.7))
        }
      }
      .frame(height: size.width * 0.1)
      .padding(.horizontal, size.width * 0.14)
      .background(.black.opacity(0.72))
    }
    .clipShape(RoundedRectangle(cornerRadius: max(7, size.width * 0.07)))
    .padding(.top, size.width * 0.1)
  }

  private var digitalCard: some View {
    coverPanel
      .overlay(alignment: .bottomLeading) {
        Label("Digital", systemImage: "arrow.down.circle.fill")
          .font(.caption2.bold())
          .foregroundStyle(theme.color(.onAccent))
          .padding(7)
          .background(theme.color(.accent).opacity(0.88), in: Capsule())
          .padding(8)
      }
      .clipShape(RoundedRectangle(cornerRadius: max(10, size.width * 0.12)))
      .overlay {
        RoundedRectangle(cornerRadius: max(10, size.width * 0.12))
          .stroke(theme.color(.divider), lineWidth: 1)
      }
  }

  @ViewBuilder
  private var coverPanel: some View {
    if let coverImageData {
      StoredImageView(data: coverImageData, contentMode: .fill)
        .clipped()
    } else {
      LinearGradient(
        colors: [platform.systemColor, theme.color(.secondaryAccent)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .overlay {
        VStack(spacing: max(4, size.width * 0.05)) {
          Image(systemName: platform.defaultObjectStyle == .cartridge ? "sparkles" : "gamecontroller.fill")
            .font(.system(size: max(16, size.width * 0.24), weight: .light))
          if size.width > 70 {
            Text(title.isEmpty ? "Your Game" : title)
              .font(.system(size: max(9, size.width * 0.09), weight: .bold))
              .lineLimit(2)
              .multilineTextAlignment(.center)
          }
        }
        .foregroundStyle(.white.opacity(0.94))
        .padding(6)
      }
    }
  }
}

import SwiftUI

struct PlatformObjectView: View {
  var platform: GamingPlatform

  var body: some View {
    GeometryReader { proxy in
      if platform == .n64 {
        RetroCartridgeView(size: proxy.size)
      } else {
        TactileCaseView(platform: platform, size: proxy.size)
      }
    }
    .shadow(color: .black.opacity(0.25), radius: 5, x: 4, y: 6)
    .accessibilityHidden(true)
  }
}

private struct TactileCaseView: View {
  var platform: GamingPlatform
  var size: CGSize

  var body: some View {
    let width = size.width
    ZStack(alignment: .leading) {
      RoundedRectangle(cornerRadius: width * 0.1)
        .fill(shellColor.gradient)
      RoundedRectangle(cornerRadius: width * 0.08)
        .fill(.black.opacity(0.15))
        .frame(width: width * 0.11)
        .padding(.vertical, width * 0.06)
      RoundedRectangle(cornerRadius: width * 0.045)
        .fill(labelGradient)
        .overlay {
          Image(systemName: platformSymbol)
            .font(.system(size: width * 0.27, weight: .light))
            .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.leading, width * 0.17)
        .padding(.trailing, width * 0.08)
        .padding(.vertical, width * 0.13)
      Capsule()
        .fill(.white.opacity(0.38))
        .frame(width: 2, height: size.height * 0.58)
        .offset(x: width * 0.14)
    }
    .overlay {
      RoundedRectangle(cornerRadius: width * 0.1)
        .stroke(.white.opacity(0.35), lineWidth: 1)
    }
    .rotation3DEffect(.degrees(-5), axis: (x: 0, y: 1, z: 0))
  }

  private var shellColor: Color {
    switch platform {
    case .playStation4: Color(red: 0.08, green: 0.27, blue: 0.72)
    case .playStation5: Color(red: 0.86, green: 0.87, blue: 0.89)
    case .switch1: Color(red: 0.82, green: 0.12, blue: 0.14)
    case .switch2: Color(red: 0.09, green: 0.09, blue: 0.1)
    case .xboxSeriesX: Color(red: 0.08, green: 0.42, blue: 0.16)
    case .n64: .gray
    }
  }

  private var labelGradient: LinearGradient {
    let accent: Color = switch platform {
    case .playStation4: .cyan
    case .playStation5: .indigo
    case .switch1: .orange
    case .switch2: .red
    case .xboxSeriesX: .green
    case .n64: .purple
    }
    return LinearGradient(colors: [accent.opacity(0.9), .black.opacity(0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
  }

  private var platformSymbol: String {
    switch platform {
    case .playStation4: "diamond.fill"
    case .playStation5: "sparkles"
    case .switch1: "circle.grid.cross.fill"
    case .switch2: "bolt.fill"
    case .xboxSeriesX: "xmark"
    case .n64: "n.square.fill"
    }
  }
}

private struct RetroCartridgeView: View {
  var size: CGSize

  var body: some View {
    let width = size.width
    VStack(spacing: 0) {
      ZStack {
        UnevenRoundedRectangle(
          topLeadingRadius: width * 0.13,
          bottomLeadingRadius: width * 0.04,
          bottomTrailingRadius: width * 0.04,
          topTrailingRadius: width * 0.13
        )
        .fill(Color(red: 0.28, green: 0.27, blue: 0.26).gradient)
        RoundedRectangle(cornerRadius: width * 0.05)
          .fill(LinearGradient(colors: [.indigo, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
          .overlay {
            Image(systemName: "sparkles")
              .font(.system(size: width * 0.26, weight: .light))
              .foregroundStyle(.white.opacity(0.9))
          }
          .padding(.horizontal, width * 0.13)
          .padding(.top, width * 0.2)
          .padding(.bottom, width * 0.11)
      }
      HStack(spacing: 2) {
        ForEach(0..<9, id: \.self) { _ in
          Rectangle().fill(Color(red: 0.76, green: 0.54, blue: 0.2))
        }
      }
      .frame(height: width * 0.12)
      .padding(.horizontal, width * 0.13)
      .background(Color(red: 0.15, green: 0.14, blue: 0.13))
    }
    .clipShape(RoundedRectangle(cornerRadius: width * 0.08))
    .padding(.top, width * 0.12)
  }
}

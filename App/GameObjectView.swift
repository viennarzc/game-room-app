import SwiftUI

struct GameObjectView: View {
  var game: Game

  var body: some View {
    Group {
      if game.platform.objectKind == .cartridge {
        CartridgeObjectView(game: game)
      } else {
        CaseObjectView(game: game)
      }
    }
    .shadow(color: .black.opacity(0.22), radius: 10, x: 7, y: 11)
  }
}

private struct CaseObjectView: View {
  var game: Game

  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: width * 0.055)
          .fill(caseColor.gradient)
          .overlay {
            RoundedRectangle(cornerRadius: width * 0.055)
              .stroke(.white.opacity(0.35), lineWidth: 1)
          }

        Rectangle()
          .fill(.black.opacity(0.22))
          .frame(width: width * 0.075)
          .padding(.vertical, width * 0.025)

        VStack(spacing: 0) {
          platformBanner
          CoverArtwork(game: game)
            .padding(width * 0.055)
        }
        .padding(.leading, width * 0.075)

        Capsule()
          .fill(.white.opacity(0.35))
          .frame(width: 2, height: width * 0.45)
          .offset(x: width * 0.095)
      }
      .rotation3DEffect(.degrees(-3), axis: (x: 0, y: 1, z: 0))
    }
  }

  private var caseColor: Color {
    switch game.platform {
    case .playStation4: .blue
    case .playStation5: .white
    case .switch1: .red
    case .switch2: .black
    case .xboxSeriesX: .green
    case .n64: .gray
    }
  }

  private var platformBanner: some View {
    Text(game.platform.shortName.uppercased())
      .font(.system(size: 10, weight: .black, design: .rounded))
      .tracking(1)
      .foregroundStyle(game.platform == .playStation5 ? .black : .white)
      .frame(maxWidth: .infinity, minHeight: 25)
      .background(.black.opacity(game.platform == .playStation5 ? 0.03 : 0.18))
  }
}

private struct CartridgeObjectView: View {
  var game: Game

  var body: some View {
    GeometryReader { proxy in
      let width = proxy.size.width
      VStack(spacing: 0) {
        RoundedRectangle(cornerRadius: width * 0.07)
          .fill(Color(red: 0.24, green: 0.23, blue: 0.22).gradient)
          .overlay(alignment: .top) {
            Capsule().fill(.black.opacity(0.45)).frame(width: width * 0.28, height: 7).padding(12)
          }
          .overlay {
            CoverArtwork(game: game)
              .padding(.horizontal, width * 0.11)
              .padding(.top, width * 0.2)
              .padding(.bottom, width * 0.12)
          }
          .overlay {
            RoundedRectangle(cornerRadius: width * 0.07).stroke(.white.opacity(0.12), lineWidth: 2)
          }

        HStack(spacing: 4) {
          ForEach(0..<11, id: \.self) { _ in
            Rectangle().fill(Color(red: 0.72, green: 0.52, blue: 0.19))
          }
        }
        .frame(height: width * 0.12)
        .padding(.horizontal, width * 0.14)
        .background(Color(red: 0.16, green: 0.15, blue: 0.14))
      }
      .clipShape(RoundedRectangle(cornerRadius: width * 0.07))
      .padding(.top, width * 0.12)
      .padding(.horizontal, width * 0.03)
    }
  }
}

private struct CoverArtwork: View {
  var game: Game

  var body: some View {
    ZStack {
      LinearGradient(colors: [game.accent.color, game.accent.color.opacity(0.35), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
      Circle().fill(.white.opacity(0.13)).scaleEffect(0.72).offset(x: 28, y: -30)
      Image(systemName: game.symbol)
        .font(.system(size: 44, weight: .thin))
        .foregroundStyle(.white.opacity(0.9))
      VStack {
        Spacer()
        Text(game.title.uppercased())
          .font(.system(size: 15, weight: .black, design: .rounded))
          .tracking(0.6)
          .multilineTextAlignment(.center)
          .foregroundStyle(.white)
          .shadow(radius: 3)
          .padding(10)
      }
    }
    .clipShape(RoundedRectangle(cornerRadius: 3))
  }
}

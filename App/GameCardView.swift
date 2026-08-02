import SwiftUI

struct GameCardView: View {
  var game: Game

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      GameObjectView(game: game)
        .aspectRatio(0.78, contentMode: .fit)
        .frame(maxWidth: .infinity)

      VStack(alignment: .leading, spacing: 4) {
        Text(game.title)
          .font(.headline)
          .foregroundStyle(Color.ink)
          .lineLimit(1)
        Text(game.platform.shortName.uppercased())
          .font(.caption2.weight(.heavy))
          .tracking(1.2)
          .foregroundStyle(.secondary)
      }
    }
    .contentShape(Rectangle())
  }
}

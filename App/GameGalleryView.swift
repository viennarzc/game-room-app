import SwiftUI

struct GameGalleryView: View {
  var games: [Game]
  var library: GameLibrary
  var namespace: Namespace.ID
  private var columns = [GridItem(.adaptive(minimum: 150, maximum: 240), spacing: 24)]

  init(games: [Game], library: GameLibrary, namespace: Namespace.ID) {
    self.games = games
    self.library = library
    self.namespace = namespace
  }

  var body: some View {
    LazyVGrid(columns: columns, spacing: 30) {
      ForEach(games) { game in
        NavigationLink(value: game.id) {
          GameCardView(game: game)
        }
        .buttonStyle(.plain)
        .matchedTransitionSource(id: game.id, in: namespace)
        .accessibilityLabel("\(game.title), \(game.platform.rawValue), \(game.status.rawValue)")
      }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 24)
    .frame(maxWidth: 1100)
    .frame(maxWidth: .infinity)
    .navigationDestination(for: String.self) { gameID in
      GameDetailView(gameID: gameID, library: library, namespace: namespace)
        .navigationTransition(.zoom(sourceID: gameID, in: namespace))
    }
  }
}

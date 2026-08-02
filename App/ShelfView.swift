import SwiftUI

struct ShelfView: View {
  var library: GameLibrary
  @Namespace private var namespace
  @State private var searchText = ""
  @State private var statusFilter: GameStatus?
  @State private var isAddingGame = false

  private var filteredGames: [Game] {
    library.games.filter { game in
      let matchesSearch = searchText.isEmpty
        || game.title.localizedCaseInsensitiveContains(searchText)
        || game.platform.rawValue.localizedCaseInsensitiveContains(searchText)
      return matchesSearch && (statusFilter == nil || game.status == statusFilter)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: 8) {
          ShelfFilterRow(selection: $statusFilter)
          if filteredGames.isEmpty {
            ContentUnavailableView.search(text: searchText)
              .frame(maxWidth: .infinity)
              .padding(.top, 60)
          } else {
            GameGalleryView(games: filteredGames, library: library, namespace: namespace)
          }
        }
        .frame(maxWidth: .infinity)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Shelf")
      .searchable(text: $searchText, prompt: "Search your shelf")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Add Game", systemImage: "plus") { isAddingGame = true }
        }
      }
      .sheet(isPresented: $isAddingGame) {
        AddGameView(library: library)
      }
    }
  }
}

private struct ShelfFilterRow: View {
  @Binding var selection: GameStatus?

  var body: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        FilterButton(title: "All", symbol: "square.grid.2x2", isSelected: selection == nil) {
          selection = nil
        }
        ForEach(GameStatus.allCases, id: \.self) { status in
          FilterButton(title: status.rawValue, symbol: status.symbol, isSelected: selection == status) {
            selection = status
          }
        }
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 8)
    }
    .scrollIndicators(.hidden)
  }
}

private struct FilterButton: View {
  var title: String
  var symbol: String
  var isSelected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: symbol)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .padding(.horizontal, 14)
        .frame(minHeight: 44)
        .background(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.regularMaterial), in: Capsule())
    }
      .buttonStyle(.plain)
      .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

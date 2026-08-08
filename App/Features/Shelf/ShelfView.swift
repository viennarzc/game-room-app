import SwiftData
import SwiftUI

struct ShelfView: View {
  @Environment(\.appTheme) private var theme
  @Query(sort: \GameEntry.dateAdded, order: .reverse) private var games: [GameEntry]

  @State private var searchText = ""
  @State private var statusFilter: GameStatus?
  @State private var isAddingGame = false

  private let columns = [GridItem(.adaptive(minimum: 150, maximum: 210), spacing: 18)]

  private var filteredGames: [GameEntry] {
    games.filter { game in
      let matchesSearch = searchText.isEmpty
        || game.title.localizedCaseInsensitiveContains(searchText)
        || game.platformDisplayName.localizedCaseInsensitiveContains(searchText)
      return matchesSearch && (statusFilter == nil || game.status == statusFilter)
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 18) {
          ShelfFilterRow(selection: $statusFilter)

          if filteredGames.isEmpty {
            ShelfEmptyState(hasGames: !games.isEmpty, searchText: searchText) {
              isAddingGame = true
            }
          } else {
            LazyVGrid(columns: columns, spacing: 22) {
              ForEach(filteredGames) { game in
                NavigationLink {
                  GameDetailView(game: game)
                } label: {
                  ShelfGameCard(game: game)
                }
                .buttonStyle(.plain)
              }
            }
          }
        }
        .padding(20)
        .frame(maxWidth: 1_100)
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .background(theme.color(.canvas))
      .navigationTitle("Shelf")
      .searchable(text: $searchText, prompt: "Games or platforms")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Add Game", systemImage: "plus") { isAddingGame = true }
        }
      }
      .sheet(isPresented: $isAddingGame) {
        AddGameView()
      }
    }
  }
}

private struct ShelfFilterRow: View {
  @Environment(\.appTheme) private var theme
  @Binding var selection: GameStatus?

  var body: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ShelfFilterButton(title: "All", symbol: "square.grid.2x2", isSelected: selection == nil) {
          selection = nil
        }
        ForEach(GameStatus.allCases) { status in
          ShelfFilterButton(title: status.rawValue, symbol: status.symbol, isSelected: selection == status) {
            selection = status
          }
        }
      }
      .padding(.vertical, 2)
    }
    .scrollIndicators(.hidden)
  }
}

private struct ShelfFilterButton: View {
  @Environment(\.appTheme) private var theme
  let title: String
  let symbol: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: symbol)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(isSelected ? theme.color(.onAccent) : theme.color(.textPrimary))
        .padding(.horizontal, 14)
        .frame(minHeight: 44)
        .background(isSelected ? theme.color(.accent) : theme.color(.surface), in: Capsule())
        .overlay {
          Capsule().stroke(isSelected ? .clear : theme.color(.divider), lineWidth: 1)
        }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

private struct ShelfGameCard: View {
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  var body: some View {
    VStack(spacing: 12) {
      GameObjectView(game: game)
        .frame(height: 186)
        .padding(.horizontal, 16)
      VStack(alignment: .leading, spacing: 5) {
        Text(game.title)
          .font(.headline)
          .lineLimit(2)
        Text(game.platformDisplayName)
          .font(.caption)
          .foregroundStyle(theme.color(.textSecondary))
        Label(game.status.rawValue, systemImage: game.status.symbol)
          .font(.caption2.weight(.semibold))
          .foregroundStyle(theme.color(.accent))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(14)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 20))
    .overlay {
      RoundedRectangle(cornerRadius: 20).stroke(theme.color(.divider), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

private struct ShelfEmptyState: View {
  let hasGames: Bool
  let searchText: String
  let addGame: () -> Void

  var body: some View {
    if hasGames {
      ContentUnavailableView.search(text: searchText)
        .frame(maxWidth: .infinity, minHeight: 360)
    } else {
      VStack(spacing: 18) {
        CollectibleHeroCard(
          asset: .gameCaseTallOptical,
          title: "Your shelf is waiting",
          description: "Add your first game to begin a collection that is entirely your own."
        )
        Button("Add a Game", systemImage: "plus", action: addGame)
          .buttonStyle(.borderedProminent)
      }
      .frame(maxWidth: .infinity, minHeight: 360)
    }
  }
}

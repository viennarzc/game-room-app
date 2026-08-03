import SwiftData
import SwiftUI

struct MemoryHomeView: View {
  @Environment(\.appTheme) private var theme
  @Query(sort: \GameEntry.dateAdded, order: .reverse) private var games: [GameEntry]
  @AppStorage("memory-resurfacing") private var memoryResurfacing = true

  @State private var isAddingGame = false
  @State private var isCapturingMoment = false
  @State private var captureGame: GameEntry?

  private var nowPlaying: [GameEntry] {
    Array(games.filter { $0.status == .playing }.prefix(5))
  }

  private var recentMemories: [MemoryMoment] {
    games
      .flatMap { game in game.sortedMoments.map { MemoryMoment(game: game, moment: $0) } }
      .sorted { $0.moment.date > $1.moment.date }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: 28) {
          if games.isEmpty {
            MemoryEmptyState { isAddingGame = true }
          } else {
            if memoryResurfacing, let resurfaced = recentMemories.last {
              NavigationLink {
                MomentDetailView(moment: resurfaced.moment)
              } label: {
                ResurfacedMemoryCard(memory: resurfaced)
              }
              .buttonStyle(.plain)
            }

            NowPlayingSection(games: nowPlaying) { game in
              captureGame = game
              isCapturingMoment = true
            }

            CaptureMomentCallout {
              captureGame = nowPlaying.first ?? games.first
              isCapturingMoment = true
            }

            RecentMemoriesSection(memories: Array(recentMemories.prefix(6)))
            ShelfSummary(games: games)
          }
        }
        .padding(20)
        .frame(maxWidth: 840)
        .frame(maxWidth: .infinity, alignment: .center)
      }
      .background(theme.color(.canvas))
      .navigationTitle("Memory")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Add Game", systemImage: "plus") { isAddingGame = true }
        }
      }
      .sheet(isPresented: $isAddingGame) {
        AddGameView()
      }
      .sheet(isPresented: $isCapturingMoment) {
        if let captureGame {
          CaptureMomentView(game: captureGame)
        }
      }
    }
  }
}

private struct MemoryEmptyState: View {
  let addGame: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Your gaming memories start here", systemImage: "sparkles")
    } description: {
      Text("Add a game, place it on your shelf, and save moments as they happen.")
    } actions: {
      Button("Add a Game", systemImage: "plus", action: addGame)
        .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, minHeight: 420)
  }
}

private struct ResurfacedMemoryCard: View {
  @Environment(\.appTheme) private var theme
  let memory: MemoryMoment

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("From your shelf", systemImage: "clock.arrow.circlepath")
        .font(.caption.bold())
        .foregroundStyle(theme.color(.textSecondary))
      Text(memory.moment.note.isEmpty ? memory.moment.title : memory.moment.note)
        .font(.title3.weight(.semibold))
        .lineLimit(3)
      HStack {
        Text(memory.game.title).font(.subheadline.weight(.medium))
        Spacer()
        Text(memory.moment.date, format: .dateTime.month(.abbreviated).day())
          .font(.caption)
          .foregroundStyle(theme.color(.textSecondary))
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 20))
    .overlay {
      RoundedRectangle(cornerRadius: 20).stroke(theme.color(.divider), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

private struct NowPlayingSection: View {
  let games: [GameEntry]
  let capture: (GameEntry) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Now Playing").font(.title2.bold())
      if games.isEmpty {
        ContentUnavailableView(
          "Nothing in progress",
          systemImage: "play.slash",
          description: Text("Mark a shelf game as Playing when you begin.")
        )
      } else {
        ScrollView(.horizontal) {
          LazyHStack(spacing: 16) {
            ForEach(games) { game in
              NowPlayingCard(game: game) { capture(game) }
            }
          }
          .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
      }
    }
  }
}

private struct NowPlayingCard: View {
  @Environment(\.appTheme) private var theme
  let game: GameEntry
  let capture: () -> Void

  var body: some View {
    HStack(spacing: 14) {
      NavigationLink {
        GameDetailView(game: game)
      } label: {
        HStack(spacing: 14) {
          GameObjectView(game: game)
            .frame(width: 66, height: 92)
          VStack(alignment: .leading, spacing: 7) {
            Text(game.title).font(.headline).lineLimit(2)
            Text(game.sortedMoments.first?.note.nilIfBlank ?? "No moments yet")
              .font(.caption)
              .foregroundStyle(theme.color(.textSecondary))
              .lineLimit(2)
          }
        }
      }
      .buttonStyle(.plain)

      Button("Capture Moment", systemImage: "plus", action: capture)
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
        .accessibilityHint("Adds a memory to \(game.title)")
    }
    .padding(14)
    .frame(width: 318, height: 132, alignment: .leading)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 20))
    .overlay {
      RoundedRectangle(cornerRadius: 20).stroke(theme.color(.divider), lineWidth: 1)
    }
  }
}

private struct CaptureMomentCallout: View {
  @Environment(\.appTheme) private var theme
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 14) {
        Image(systemName: "square.and.pencil")
          .font(.title2)
        VStack(alignment: .leading, spacing: 2) {
          Text("Capture Moment").font(.headline)
          Text("Save what made this session matter.").font(.subheadline).opacity(0.82)
        }
        Spacer()
        Image(systemName: "chevron.forward").font(.caption.bold())
      }
      .foregroundStyle(theme.color(.onAccent))
      .padding(18)
      .frame(maxWidth: .infinity, minHeight: 72)
      .background(theme.color(.accent), in: RoundedRectangle(cornerRadius: 18))
    }
    .buttonStyle(.plain)
  }
}

private struct RecentMemoriesSection: View {
  let memories: [MemoryMoment]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Recent Memories").font(.title2.bold())
      if memories.isEmpty {
        ContentUnavailableView(
          "No moments yet",
          systemImage: "text.book.closed",
          description: Text("Your journal entries will appear here.")
        )
      } else {
        LazyVStack(spacing: 12) {
          ForEach(memories) { memory in
            NavigationLink {
              MomentDetailView(moment: memory.moment)
            } label: {
              MemoryCard(memory: memory)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}

struct MemoryCard: View {
  @Environment(\.appTheme) private var theme
  let memory: MemoryMoment

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: memory.moment.type.symbol)
        .foregroundStyle(theme.color(.accent))
        .frame(width: 38, height: 38)
        .background(theme.color(.accent).opacity(0.12), in: Circle())
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(memory.moment.title).font(.headline)
          Spacer()
          Text(memory.moment.date, format: .dateTime.month(.abbreviated).day())
            .font(.caption)
            .foregroundStyle(theme.color(.textSecondary))
        }
        Text(memory.game.title)
          .font(.caption.weight(.semibold))
          .foregroundStyle(theme.color(.textSecondary))
        if !memory.moment.note.isEmpty {
          Text(memory.moment.note).lineLimit(3)
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16).stroke(theme.color(.divider), lineWidth: 1)
    }
    .accessibilityElement(children: .combine)
  }
}

private struct ShelfSummary: View {
  let games: [GameEntry]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Your Shelf").font(.title2.bold())
      HStack(spacing: 10) {
        SummaryCount(label: "Playing", count: games.filter { $0.status == .playing }.count, symbol: "play.fill")
        SummaryCount(label: "Finished", count: games.filter { $0.status == .finished }.count, symbol: "checkmark")
        SummaryCount(label: "Memories", count: games.reduce(0) { $0 + ($1.moments?.count ?? 0) }, symbol: "sparkles")
      }
    }
  }
}

private struct SummaryCount: View {
  @Environment(\.appTheme) private var theme
  let label: String
  let count: Int
  let symbol: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: symbol).foregroundStyle(theme.color(.accent))
      Text(count, format: .number).font(.title2.bold())
      Text(label).font(.caption).foregroundStyle(theme.color(.textSecondary))
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 16))
  }
}

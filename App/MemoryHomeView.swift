import SwiftUI

struct MemoryHomeView: View {
  var library: GameLibrary
  @Namespace private var namespace
  @AppStorage("memory-resurfacing") private var memoryResurfacing = true
  @State private var isCapturing = false
  @State private var captureGameID: String?
  @State private var isAddingGame = false
  @State private var isShowingSettings = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 32) {
          if library.games.isEmpty {
            MemoryEmptyState { isAddingGame = true }
          } else {
            if memoryResurfacing, let resurfaced = library.recentMoments.last {
              NavigationLink(value: resurfaced.id) {
                ResurfacedMemoryCard(memory: resurfaced)
              }
              .buttonStyle(.plain)
            }
            NowPlayingSection(games: library.nowPlaying, namespace: namespace) { gameID in
              captureGameID = gameID
              isCapturing = true
            }
            CaptureMomentCallout {
              captureGameID = library.nowPlaying.first?.id ?? library.games.first?.id
              isCapturing = true
            }
            RecentMemoriesSection(memories: Array(library.recentMoments.prefix(5)))
            ShelfPreviewSection(games: library.games)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: 760)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Memory")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Settings", systemImage: "gearshape") { isShowingSettings = true }
        }
      }
      .navigationDestination(for: String.self) { gameID in
        GameDetailView(gameID: gameID, library: library, namespace: namespace)
          .navigationTransition(.zoom(sourceID: gameID, in: namespace))
      }
      .navigationDestination(for: UUID.self) { momentID in
        MomentDetailView(momentID: momentID, library: library)
      }
      .sheet(isPresented: $isCapturing) {
        CaptureMomentView(library: library, gameID: captureGameID)
      }
      .sheet(isPresented: $isAddingGame) {
        AddGameView(library: library)
      }
      .sheet(isPresented: $isShowingSettings) {
        SettingsView()
      }
    }
  }
}

private struct MemoryEmptyState: View {
  var addGame: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Your gaming memories start here", systemImage: "sparkles")
    } description: {
      Text("Add a game, then save the moments you want to keep.")
    } actions: {
      Button("Add a Game", systemImage: "plus", action: addGame)
        .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 80)
  }
}

private struct ResurfacedMemoryCard: View {
  var memory: MemoryMoment

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label("From your shelf", systemImage: "clock.arrow.circlepath")
        .font(.caption.bold())
        .foregroundStyle(.secondary)
      Text(memory.moment.note.isEmpty ? memory.moment.title : memory.moment.note)
        .font(.title3.weight(.semibold))
        .lineLimit(3)
      HStack {
        Text(memory.game.title).font(.subheadline.weight(.medium))
        Spacer()
        Text(memory.moment.date, format: .dateTime.month(.abbreviated).day())
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
    .padding(20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    .accessibilityElement(children: .combine)
  }
}

private struct NowPlayingSection: View {
  var games: [Game]
  var namespace: Namespace.ID
  var capture: (String) -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Now Playing").font(.title2.bold())
      if games.isEmpty {
        Text("Choose a game from your shelf and mark it Playing.")
          .font(.body)
          .foregroundStyle(.secondary)
          .padding(.vertical, 12)
      } else {
        ScrollView(.horizontal) {
          HStack(spacing: 16) {
            ForEach(games) { game in
              NowPlayingCard(game: game, namespace: namespace) { capture(game.id) }
            }
          }
        }
        .scrollIndicators(.hidden)
      }
    }
  }
}

private struct NowPlayingCard: View {
  var game: Game
  var namespace: Namespace.ID
  var capture: () -> Void

  var body: some View {
    HStack(spacing: 14) {
      NavigationLink(value: game.id) {
        HStack(spacing: 14) {
          GameObjectView(game: game)
            .frame(width: 66, height: 92)
            .accessibilityHidden(true)
          VStack(alignment: .leading, spacing: 7) {
            Text(game.title).font(.headline).lineLimit(2)
            Text(game.moments.first?.note ?? "No moments yet")
              .font(.caption)
              .foregroundStyle(.secondary)
              .lineLimit(2)
          }
        }
      }
      .buttonStyle(.plain)
      .matchedTransitionSource(id: game.id, in: namespace)
      Button("Capture Moment", systemImage: "plus", action: capture)
        .labelStyle(.iconOnly)
        .buttonStyle(.borderedProminent)
        .accessibilityHint("Adds a memory to \(game.title)")
    }
    .padding(14)
    .frame(width: 310, height: 132, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    .accessibilityElement(children: .contain)
    .accessibilityLabel("\(game.title), \(game.platform.rawValue), Playing")
  }
}

private struct CaptureMomentCallout: View {
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 14) {
        Image(systemName: "square.and.pencil")
          .font(.title2)
        VStack(alignment: .leading, spacing: 2) {
          Text("Capture Moment").font(.headline)
          Text("Save what made this session matter.").font(.subheadline).opacity(0.8)
        }
        Spacer()
        Image(systemName: "chevron.right").font(.caption.bold())
      }
      .foregroundStyle(.white)
      .padding(18)
      .frame(maxWidth: .infinity, minHeight: 72)
      .background(Color(red: 0.13, green: 0.32, blue: 0.62), in: RoundedRectangle(cornerRadius: 18))
    }
    .buttonStyle(.plain)
  }
}

private struct RecentMemoriesSection: View {
  var memories: [MemoryMoment]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Recent Memories").font(.title2.bold())
      if memories.isEmpty {
        Text("Your saved moments will appear here.")
          .foregroundStyle(.secondary)
      } else {
        VStack(spacing: 12) {
          ForEach(memories) { memory in
            NavigationLink(value: memory.id) {
              MemoryCard(memory: memory)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}

private struct MemoryCard: View {
  var memory: MemoryMoment

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: memory.moment.kind.symbol)
        .foregroundStyle(.tint)
        .frame(width: 36, height: 36)
        .background(.tint.opacity(0.12), in: Circle())
      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(memory.moment.title).font(.headline)
          Spacer()
          Text(memory.moment.date, format: .dateTime.month(.abbreviated).day())
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Text(memory.game.title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        if !memory.moment.note.isEmpty {
          Text(memory.moment.note).font(.body).lineLimit(3)
        }
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .combine)
  }
}

private struct ShelfPreviewSection: View {
  var games: [Game]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Your Shelf").font(.title2.bold())
      HStack(spacing: 10) {
        StatusCount(label: "Playing", count: games.filter { $0.status == .playing }.count, symbol: "play.fill")
        StatusCount(label: "Finished", count: games.filter { $0.status == .finished }.count, symbol: "checkmark")
        StatusCount(label: "Memories", count: games.reduce(0) { $0 + $1.moments.count }, symbol: "sparkles")
      }
    }
  }
}

private struct StatusCount: View {
  var label: String
  var count: Int
  var symbol: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Image(systemName: symbol).foregroundStyle(.tint)
      Text(count, format: .number).font(.title2.bold())
      Text(label).font(.caption).foregroundStyle(.secondary)
    }
    .padding(14)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    .accessibilityElement(children: .combine)
  }
}

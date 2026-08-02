import Observation
import SwiftUI

struct Game: Identifiable, Hashable, Codable {
  var id: String
  var title: String
  var subtitle: String
  var platform: GamingPlatform
  var status: GameStatus
  var accent: GameAccent
  var symbol: String
  var notes: String
  var moments: [GameMoment]

  static var samples: [Game] = [
    Game(id: "starfall-64", title: "Starfall 64", subtitle: "Beyond the velvet sky", platform: .n64, status: .finished, accent: .indigo, symbol: "sparkles", notes: "The final observatory still feels magical.", moments: [.sample("First launch", "A rainy Saturday and that unforgettable title screen.", .started), .sample("Crystal Cavern", "Finally found the hidden route behind the waterfall.", .discovery), .sample("Credits", "Finished at 1:42 AM. Worth it.", .finished)]),
    Game(id: "driftline", title: "Driftline", subtitle: "Night circuit", platform: .playStation4, status: .playing, accent: .pink, symbol: "steeringwheel", notes: "Working through the coastal championship.", moments: [.sample("First drive", "Picked the silver coupe.", .started), .sample("12 hours", "Unlocked the mountain pass.", .session)]),
    Game(id: "ashen-crown", title: "Ashen Crown", subtitle: "A kingdom remembers", platform: .playStation5, status: .playing, accent: .orange, symbol: "crown.fill", notes: "Explore the western ruins before advancing the story.", moments: [.sample("The gates open", "The scale of the capital is incredible.", .started)]),
    Game(id: "island-atelier", title: "Island Atelier", subtitle: "Make a little paradise", platform: .switch1, status: .wantToPlay, accent: .mint, symbol: "leaf.fill", notes: "Perfect for the next quiet weekend.", moments: []),
    Game(id: "neon-rally", title: "Neon Rally", subtitle: "Every corner counts", platform: .switch2, status: .playing, accent: .cyan, symbol: "bolt.fill", notes: "Try motion controls again after the next update.", moments: [.sample("25 hours", "Gold on every Metro Cup event.", .session)]),
    Game(id: "deep-signal", title: "Deep Signal", subtitle: "Answer the unknown", platform: .xboxSeriesX, status: .finished, accent: .green, symbol: "antenna.radiowaves.left.and.right", notes: "A brilliant slow-burn mystery.", moments: [.sample("Signal found", "Headphones made this opening perfect.", .started), .sample("Transmission ended", "Sat through every second of the credits.", .finished)])
  ]
}

enum GameAccent: String, Codable, Hashable {
  case indigo, pink, orange, mint, cyan, green

  var color: Color {
    switch self {
    case .indigo: .indigo
    case .pink: .pink
    case .orange: .orange
    case .mint: .mint
    case .cyan: .cyan
    case .green: .green
    }
  }
}

enum GamingPlatform: String, CaseIterable, Hashable, Codable {
  case n64 = "Nintendo 64"
  case playStation4 = "PlayStation 4"
  case playStation5 = "PlayStation 5"
  case switch1 = "Nintendo Switch"
  case switch2 = "Nintendo Switch 2"
  case xboxSeriesX = "Xbox Series X"

  var shortName: String {
    switch self {
    case .n64: "N64"
    case .playStation4: "PS4"
    case .playStation5: "PS5"
    case .switch1: "Switch"
    case .switch2: "Switch 2"
    case .xboxSeriesX: "Series X"
    }
  }

  var objectKind: GameObjectKind {
    self == .n64 ? .cartridge : .gameCase
  }

  var defaultAccent: GameAccent {
    switch self {
    case .n64: .indigo
    case .playStation4: .cyan
    case .playStation5: .orange
    case .switch1: .pink
    case .switch2: .cyan
    case .xboxSeriesX: .green
    }
  }
}

enum GameObjectKind: Hashable {
  case cartridge
  case gameCase
}

enum GameStatus: String, CaseIterable, Hashable, Codable {
  case playing = "Playing"
  case wantToPlay = "Want to Play"
  case paused = "Paused"
  case finished = "Finished"
  case dropped = "Dropped"

  var symbol: String {
    switch self {
    case .playing: "play.fill"
    case .wantToPlay: "bookmark.fill"
    case .paused: "pause.fill"
    case .finished: "checkmark"
    case .dropped: "arrow.down.right"
    }
  }
}

struct GameMoment: Identifiable, Hashable, Codable {
  var id: UUID
  var title: String
  var note: String
  var date: Date
  var kind: MomentKind
  var photoData: Data?
  var mood: String?
  var playedWith: String?
  var durationMinutes: Int?
  var vibe: String?

  init(
    id: UUID,
    title: String,
    note: String,
    date: Date,
    kind: MomentKind,
    photoData: Data? = nil,
    mood: String? = nil,
    playedWith: String? = nil,
    durationMinutes: Int? = nil,
    vibe: String? = nil
  ) {
    self.id = id
    self.title = title
    self.note = note
    self.date = date
    self.kind = kind
    self.photoData = photoData
    self.mood = mood
    self.playedWith = playedWith
    self.durationMinutes = durationMinutes
    self.vibe = vibe
  }

  static func sample(_ title: String, _ note: String, _ kind: MomentKind) -> GameMoment {
    GameMoment(id: UUID(), title: title, note: note, date: .now, kind: kind)
  }
}

enum MomentKind: String, CaseIterable, Hashable, Codable {
  case started = "Started"
  case discovery = "Discovery"
  case milestone = "Milestone"
  case achievement = "Achievement"
  case playedTogether = "Played Together"
  case session = "Session"
  case bought = "Bought or Unboxed"
  case paused = "Paused"
  case finished = "Finished"
  case memory = "Memory"

  var symbol: String {
    switch self {
    case .started: "play.fill"
    case .discovery: "binoculars.fill"
    case .milestone: "signpost.right.fill"
    case .achievement: "trophy.fill"
    case .playedTogether: "person.2.fill"
    case .session: "clock.fill"
    case .bought: "shippingbox.fill"
    case .paused: "pause.fill"
    case .finished: "flag.checkered"
    case .memory: "sparkles"
    }
  }

  var prompt: String {
    switch self {
    case .started: "What made this first session memorable?"
    case .discovery: "What did you discover?"
    case .milestone: "What changed in your journey?"
    case .achievement: "What are you proud of?"
    case .playedTogether: "Who were you playing with?"
    case .session: "What do you want to remember from this session?"
    case .bought: "What made getting this game special?"
    case .paused: "Where are you leaving the story for now?"
    case .finished: "What do you want to remember about the ending?"
    case .memory: "What happened?"
    }
  }
}

struct MemoryMoment: Identifiable, Hashable {
  var game: Game
  var moment: GameMoment

  var id: UUID { moment.id }
}

extension Color {
  static var galleryBackground: Color { Color(red: 0.94, green: 0.91, blue: 0.86) }
  static var ink: Color { Color(red: 0.12, green: 0.11, blue: 0.14) }
}

@MainActor
@Observable
final class GameLibrary {
  var games: [Game]
  private let storageKey = "game-room.library"

  init() {
    if let data = UserDefaults.standard.data(forKey: storageKey),
       let savedGames = try? JSONDecoder().decode([Game].self, from: data) {
      games = savedGames
    } else {
      games = Game.samples
    }
  }

  func game(id: String) -> Game? {
    games.first { $0.id == id }
  }

  func updateStatus(_ status: GameStatus, for gameID: String) {
    update(gameID) { $0.status = status }
  }

  func updateNotes(_ notes: String, for gameID: String) {
    update(gameID) { $0.notes = notes }
  }

  func addMoment(_ moment: GameMoment, to gameID: String) {
    update(gameID) { $0.moments.insert(moment, at: 0) }
  }

  func updateMoment(_ moment: GameMoment) {
    guard let gameIndex = games.firstIndex(where: { game in game.moments.contains(where: { $0.id == moment.id }) }),
          let momentIndex = games[gameIndex].moments.firstIndex(where: { $0.id == moment.id }) else { return }
    games[gameIndex].moments[momentIndex] = moment
    persist()
  }

  func deleteMoment(id: UUID) {
    guard let gameIndex = games.firstIndex(where: { game in game.moments.contains(where: { $0.id == id }) }) else { return }
    games[gameIndex].moments.removeAll { $0.id == id }
    persist()
  }

  func memoryMoment(id: UUID) -> MemoryMoment? {
    recentMoments.first { $0.id == id }
  }

  func addGame(title: String, platform: GamingPlatform, status: GameStatus) {
    let game = Game(
      id: UUID().uuidString,
      title: title,
      subtitle: "A new story begins",
      platform: platform,
      status: status,
      accent: platform.defaultAccent,
      symbol: "gamecontroller.fill",
      notes: "",
      moments: []
    )
    games.insert(game, at: 0)
    persist()
  }

  var nowPlaying: [Game] {
    Array(games.filter { $0.status == .playing }.prefix(5))
  }

  var recentMoments: [MemoryMoment] {
    games
      .flatMap { game in game.moments.map { MemoryMoment(game: game, moment: $0) } }
      .sorted { $0.moment.date > $1.moment.date }
  }

  private func update(_ gameID: String, change: (inout Game) -> Void) {
    guard let index = games.firstIndex(where: { $0.id == gameID }) else { return }
    change(&games[index])
    persist()
  }

  private func persist() {
    guard let data = try? JSONEncoder().encode(games) else { return }
    UserDefaults.standard.set(data, forKey: storageKey)
  }
}

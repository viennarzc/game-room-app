import Foundation
import SwiftUI

enum GameStatus: String, CaseIterable, Codable, Identifiable, Sendable {
  case playing = "Playing"
  case backlog = "Backlog"
  case finished = "Finished"
  case paused = "Paused"

  var id: String { rawValue }

  var symbol: String {
    switch self {
    case .playing: "play.fill"
    case .backlog: "bookmark.fill"
    case .finished: "checkmark.circle.fill"
    case .paused: "pause.fill"
    }
  }
}

enum OwnershipType: String, CaseIterable, Codable, Identifiable, Sendable {
  case physical = "Physical"
  case digital = "Digital"
  case subscription = "Subscription"
  case borrowed = "Borrowed"

  var id: String { rawValue }

  var symbol: String {
    switch self {
    case .physical: "shippingbox.fill"
    case .digital: "arrow.down.circle.fill"
    case .subscription: "rectangle.stack.badge.play.fill"
    case .borrowed: "person.2.fill"
    }
  }
}

enum PlayStyle: String, CaseIterable, Codable, Identifiable, Sendable {
  case cozy = "Cozy"
  case backlogClearer = "Backlog clearer"
  case completionist = "Completionist"
  case collector = "Collector"
  case multiplayer = "Multiplayer"
  case storyDriven = "Story-driven"

  var id: String { rawValue }
}

enum MomentType: String, CaseIterable, Codable, Identifiable, Sendable {
  case started = "Started"
  case bought = "Bought or Unboxed"
  case milestone = "Milestone"
  case achievement = "Achievement"
  case session = "Played Session"
  case together = "Played Together"
  case finished = "Finished"
  case paused = "Paused or Dropped"
  case memory = "Memory"

  var id: String { rawValue }

  var symbol: String {
    switch self {
    case .started: "play.fill"
    case .bought: "shippingbox.fill"
    case .milestone: "signpost.right.fill"
    case .achievement: "trophy.fill"
    case .session: "clock.fill"
    case .together: "person.2.fill"
    case .finished: "flag.checkered"
    case .paused: "pause.fill"
    case .memory: "sparkles"
    }
  }

  var prompt: LocalizedStringResource {
    switch self {
    case .started: "What made this first session memorable?"
    case .bought: "What made getting this game special?"
    case .milestone: "What changed in your journey?"
    case .achievement: "What are you proud of?"
    case .session: "What do you want to remember from this session?"
    case .together: "Who were you playing with?"
    case .finished: "What do you want to remember about the ending?"
    case .paused: "Where are you leaving the story for now?"
    case .memory: "What happened?"
    }
  }
}

enum GameObjectStyle: String, CaseIterable, Codable, Identifiable, Sendable {
  case slimCase = "Slim Case"
  case tallCase = "Tall Case"
  case cartridge = "Cartridge"
  case digitalCard = "Digital Card"
  case collectorCard = "Collector Card"

  var id: String { rawValue }
}

enum GamingPlatform: String, CaseIterable, Codable, Identifiable, Sendable {
  case playStation5 = "PlayStation 5"
  case playStation4 = "PlayStation 4"
  case xboxSeries = "Xbox Series"
  case xboxOne = "Xbox One"
  case switch2 = "Nintendo Switch 2"
  case nintendoSwitch = "Nintendo Switch"
  case nintendo64 = "Nintendo 64"
  case gameCube = "Nintendo GameCube"
  case nes = "Nintendo Entertainment System"
  case snes = "Super Nintendo"
  case segaGenesis = "Sega Genesis"
  case dreamcast = "Sega Dreamcast"
  case pc = "Windows PC"
  case mac = "Mac"
  case steamDeck = "Steam Deck"
  case mobile = "Mobile"
  case other = "Other"

  var id: String { rawValue }

  var shortName: String {
    switch self {
    case .playStation5: "PS5"
    case .playStation4: "PS4"
    case .xboxSeries: "Xbox Series"
    case .xboxOne: "Xbox One"
    case .switch2: "Switch 2"
    case .nintendoSwitch: "Switch"
    case .nintendo64: "N64"
    case .gameCube: "GameCube"
    case .nes: "NES"
    case .snes: "SNES"
    case .segaGenesis: "Genesis"
    case .dreamcast: "Dreamcast"
    case .pc: "PC"
    case .mac: "Mac"
    case .steamDeck: "Steam Deck"
    case .mobile: "Mobile"
    case .other: "Other"
    }
  }

  var defaultObjectStyle: GameObjectStyle {
    switch self {
    case .nintendo64, .nes, .snes, .segaGenesis: .cartridge
    case .pc, .mac, .steamDeck, .mobile: .digitalCard
    case .nintendoSwitch, .switch2: .slimCase
    case .other: .collectorCard
    default: .tallCase
    }
  }

  var suggestedTheme: ThemeID {
    switch self {
    case .playStation4, .playStation5: .midnightBlue
    case .xboxOne, .xboxSeries: .velocityGreen
    case .nintendoSwitch, .switch2, .gameCube: .joyRed
    case .nintendo64, .nes, .snes: .eightBitClassic
    case .segaGenesis, .dreamcast: .arcadeCobalt
    case .pc, .mac, .steamDeck, .mobile, .other: .desktopGraphite
    }
  }

  var systemColor: Color {
    switch self {
    case .playStation4, .playStation5: .indigo
    case .xboxOne, .xboxSeries: .green
    case .nintendoSwitch, .switch2: .red
    case .nintendo64, .gameCube: .purple
    case .nes, .snes: .gray
    case .segaGenesis, .dreamcast: .blue
    case .pc, .mac, .steamDeck: .cyan
    case .mobile: .orange
    case .other: .secondary
    }
  }
}

extension String {
  var nilIfBlank: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

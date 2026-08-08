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
  case playStation3 = "PlayStation 3"
  case playStation2 = "PlayStation 2"
  case playStation = "PlayStation"
  case psp = "PlayStation Portable"
  case playStationVita = "PlayStation Vita"
  case xboxSeries = "Xbox Series"
  case xboxOne = "Xbox One"
  case xbox360 = "Xbox 360"
  case xbox = "Xbox"
  case switch2 = "Nintendo Switch 2"
  case nintendoSwitch = "Nintendo Switch"
  case wiiU = "Nintendo Wii U"
  case wii = "Nintendo Wii"
  case nintendo64 = "Nintendo 64"
  case gameCube = "Nintendo GameCube"
  case nes = "Nintendo Entertainment System"
  case snes = "Super Nintendo"
  case nintendo3DS = "Nintendo 3DS"
  case nintendoDS = "Nintendo DS"
  case gameBoyAdvance = "Game Boy Advance"
  case gameBoyColor = "Game Boy Color"
  case gameBoy = "Game Boy"
  case segaGenesis = "Sega Genesis"
  case dreamcast = "Sega Dreamcast"
  case segaSaturn = "Sega Saturn"
  case masterSystem = "Sega Master System"
  case gameGear = "Sega Game Gear"
  case atari = "Atari"
  case turboGrafx16 = "TurboGrafx-16"
  case neoGeo = "Neo Geo"
  case arcade = "Arcade"
  case pc = "Windows PC"
  case mac = "Mac"
  case steamDeck = "Steam Deck"
  case handheldPC = "Handheld PC"
  case mobile = "Mobile"
  case virtualReality = "Virtual Reality"
  case other = "Other"

  var id: String { rawValue }

  var shortName: String {
    switch self {
    case .playStation5: "PS5"
    case .playStation4: "PS4"
    case .playStation3: "PS3"
    case .playStation2: "PS2"
    case .playStation: "PS1"
    case .psp: "PSP"
    case .playStationVita: "PS Vita"
    case .xboxSeries: "Xbox Series"
    case .xboxOne: "Xbox One"
    case .xbox360: "Xbox 360"
    case .xbox: "Xbox"
    case .switch2: "Switch 2"
    case .nintendoSwitch: "Switch"
    case .wiiU: "Wii U"
    case .wii: "Wii"
    case .nintendo64: "N64"
    case .gameCube: "GameCube"
    case .nes: "NES"
    case .snes: "SNES"
    case .nintendo3DS: "3DS"
    case .nintendoDS: "DS"
    case .gameBoyAdvance: "GBA"
    case .gameBoyColor: "Game Boy Color"
    case .gameBoy: "Game Boy"
    case .segaGenesis: "Genesis"
    case .dreamcast: "Dreamcast"
    case .segaSaturn: "Saturn"
    case .masterSystem: "Master System"
    case .gameGear: "Game Gear"
    case .atari: "Atari"
    case .turboGrafx16: "TurboGrafx-16"
    case .neoGeo: "Neo Geo"
    case .arcade: "Arcade"
    case .pc: "PC"
    case .mac: "Mac"
    case .steamDeck: "Steam Deck"
    case .handheldPC: "Handheld PC"
    case .mobile: "Mobile"
    case .virtualReality: "VR"
    case .other: "Other"
    }
  }

  var defaultObjectStyle: GameObjectStyle {
    switch self {
    case .nintendo64, .nes, .snes, .segaGenesis, .masterSystem,
         .atari, .turboGrafx16, .neoGeo: .cartridge
    case .pc, .mac, .steamDeck, .handheldPC, .mobile, .virtualReality,
         .arcade: .digitalCard
    case .nintendoSwitch, .switch2: .slimCase
    case .other: .collectorCard
    default: .tallCase
    }
  }

  var suggestedTheme: ThemeID {
    switch self {
    case .playStation, .playStation2, .playStation3, .playStation4,
         .playStation5, .psp, .playStationVita: .midnightBlue
    case .xbox, .xbox360, .xboxOne, .xboxSeries: .velocityGreen
    case .nintendoSwitch, .switch2, .wii, .wiiU, .gameCube,
         .nintendo3DS, .nintendoDS, .gameBoyAdvance, .gameBoyColor,
         .gameBoy: .joyRed
    case .nintendo64, .nes, .snes, .atari, .turboGrafx16, .neoGeo: .eightBitClassic
    case .segaGenesis, .dreamcast, .segaSaturn, .masterSystem,
         .gameGear, .arcade: .arcadeCobalt
    case .pc, .mac, .steamDeck, .handheldPC, .mobile,
         .virtualReality, .other: .desktopGraphite
    }
  }

  var systemColor: Color {
    switch self {
    case .playStation, .playStation2, .playStation3, .playStation4,
         .playStation5, .psp, .playStationVita: .indigo
    case .xbox, .xbox360, .xboxOne, .xboxSeries: .green
    case .nintendoSwitch, .switch2, .wii, .wiiU: .red
    case .nintendo64, .gameCube, .nintendo3DS, .nintendoDS,
         .gameBoyAdvance, .gameBoyColor, .gameBoy: .purple
    case .nes, .snes, .atari, .turboGrafx16, .neoGeo: .gray
    case .segaGenesis, .dreamcast, .segaSaturn, .masterSystem,
         .gameGear, .arcade: .blue
    case .pc, .mac, .steamDeck, .handheldPC, .virtualReality: .cyan
    case .mobile: .orange
    case .other: .secondary
    }
  }

  var collectibleAsset: CollectibleAssetID? {
    switch self {
    case .playStation5: .currentSculpturalHomeConsole
    case .playStation4: .controllerLate2010sSymmetric
    case .playStation3: .consoleLate2000sGlossy
    case .playStation2: .consoleEarly2000sBlack
    case .playStation: .controllerMid1990sDualGrip
    case .psp: .handheldMid2000sDisc
    case .playStationVita: .handheldEarly2010sTouch
    case .xboxSeries: .currentBlackTowerConsole
    case .xboxOne: .consoleLate2010sFlat
    case .xbox360: .consoleMid2000sWhite
    case .xbox: .consoleEarly2000sBold
    case .switch2: .currentNextHybridConsole
    case .nintendoSwitch: .currentClassicHybridConsole
    case .wiiU: .consoleTabletHybrid
    case .wii: .consoleMotionSlim
    case .nintendo64: .controllerThreeProng
    case .gameCube: .consoleCompactCube
    case .nes: .controllerEightBitRectangular
    case .snes: .controllerSixteenBitRounded
    case .nintendo3DS: .handheldDualScreenDimensional
    case .nintendoDS: .handheldDualScreen
    case .gameBoyAdvance: .handheldEarly2000sWide
    case .gameBoyColor: .handheldColorVertical
    case .gameBoy: .handheldMonochromeVertical
    case .segaGenesis, .masterSystem: .controllerSixButtonClassic
    case .dreamcast: .consoleDiscEraWhite
    case .segaSaturn: .controllerDiscEraRound
    case .gameGear: .handheldLandscapeClassic
    case .atari: .consoleWoodgrainClassic
    case .turboGrafx16: .consoleCompactCardBased
    case .neoGeo: .consolePremiumCartridge
    case .arcade: .arcadeCabinet
    case .pc: .currentDesktopGamingPC
    case .mac: .currentGamingLaptop
    case .steamDeck, .handheldPC: .currentHandheldGamingPC
    case .mobile: .currentMobileGaming
    case .virtualReality: .currentSpatialGamingHeadset
    case .other: nil
    }
  }
}

extension String {
  var nilIfBlank: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

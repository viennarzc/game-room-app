import Foundation

enum CollectibleAssetPack: String, CaseIterable, Identifiable, Sendable {
  case starter = "collectibles-starter"
  case current = "collectibles-current"
  case playHistory = "collectibles-play-history"
  case xboxHistory = "collectibles-xbox-history"
  case nintendoHistory = "collectibles-nintendo-history"
  case segaAndArcade = "collectibles-sega-arcade"
  case gameMedia = "collectibles-game-media"

  var id: String { rawValue }

  var name: LocalizedStringResource {
    switch self {
    case .starter: "Essential Collection"
    case .current: "Modern Systems"
    case .playHistory: "Play History"
    case .xboxHistory: "Xbox History"
    case .nintendoHistory: "Nintendo History"
    case .segaAndArcade: "Arcade & Classics"
    case .gameMedia: "Game Media"
    }
  }

  var summary: LocalizedStringResource {
    switch self {
    case .starter: "Foundational controllers and handhelds"
    case .current: "Home, hybrid, PC, mobile, and spatial play"
    case .playHistory: "Disc-era home systems and handhelds"
    case .xboxHistory: "Three generations of bold home consoles"
    case .nintendoHistory: "Home consoles and portable favorites"
    case .segaAndArcade: "Arcade cabinets and classic ways to play"
    case .gameMedia: "Cases, cartridges, saves, and memory keepsakes"
    }
  }

  var symbolName: String {
    switch self {
    case .starter: "gamecontroller.fill"
    case .current: "sparkles.tv.fill"
    case .playHistory: "playstation.logo"
    case .xboxHistory: "xbox.logo"
    case .nintendoHistory: "hand.raised.fingers.spread.fill"
    case .segaAndArcade: "arcade.stick.console.fill"
    case .gameMedia: "opticaldisc.fill"
    }
  }

  var assets: [CollectibleAssetID] {
    Self.assetsByPack[self, default: []]
  }

  private static let assetsByPack = Dictionary(
    grouping: CollectibleAssetID.allCases,
    by: \.pack
  )
}

enum CollectibleAssetID: String, CaseIterable, Identifiable, Sendable {
  // Approved starter set
  case controllerLate2010sSymmetric = "controller-late-2010s-symmetric"
  case controllerEightBitRectangular = "controller-eight-bit-rectangular"
  case controllerSixteenBitRounded = "controller-sixteen-bit-rounded"
  case controllerMid1990sDualGrip = "controller-mid-1990s-dual-grip"
  case handheldMonochromeVertical = "handheld-monochrome-vertical"
  case handheldEarly2000sWide = "handheld-early-2000s-wide"

  // Current platform collection
  case currentSculpturalHomeConsole = "current-sculptural-home-console"
  case currentBlackTowerConsole = "current-black-tower-console"
  case currentCompactDigitalConsole = "current-compact-digital-console"
  case currentNextHybridConsole = "current-next-hybrid-console"
  case currentClassicHybridConsole = "current-classic-hybrid-console"
  case currentHandheldGamingPC = "current-handheld-gaming-pc"
  case currentDesktopGamingPC = "current-desktop-gaming-pc"
  case currentGamingLaptop = "current-gaming-laptop"
  case currentMobileGaming = "current-mobile-gaming"
  case currentSpatialGamingHeadset = "current-spatial-gaming-headset"

  // Play-focused history
  case consoleEarly2000sBlack = "console-early-2000s-black"
  case consoleLate2000sGlossy = "console-late-2000s-glossy"
  case handheldMid2000sDisc = "handheld-mid-2000s-disc"
  case handheldEarly2010sTouch = "handheld-early-2010s-touch"

  // Xbox-focused history
  case consoleEarly2000sBold = "console-early-2000s-bold"
  case consoleMid2000sWhite = "console-mid-2000s-white"
  case consoleLate2010sFlat = "console-late-2010s-flat"

  // Nintendo-focused history
  case controllerThreeProng = "controller-three-prong"
  case consoleCompactCube = "console-compact-cube"
  case consoleMotionSlim = "console-motion-slim"
  case consoleTabletHybrid = "console-tablet-hybrid"
  case handheldColorVertical = "handheld-color-vertical"
  case handheldDualScreen = "handheld-dual-screen"
  case handheldDualScreenDimensional = "handheld-dual-screen-dimensional"

  // Sega, arcade, and other classics
  case controllerSixButtonClassic = "controller-six-button-classic"
  case controllerDiscEraRound = "controller-disc-era-round"
  case consoleDiscEraWhite = "console-disc-era-white"
  case handheldLandscapeClassic = "handheld-landscape-classic"
  case consoleWoodgrainClassic = "console-woodgrain-classic"
  case consoleCompactCardBased = "console-compact-card-based"
  case consolePremiumCartridge = "console-premium-cartridge"
  case arcadeCabinet = "arcade-cabinet"

  // Generic game and memory objects
  case gameCaseTallOptical = "game-case-tall-optical"
  case gameCaseSlimHybrid = "game-case-slim-hybrid"
  case gameCartridgeEightBit = "game-cartridge-eight-bit"
  case gameCartridgeSixteenBit = "game-cartridge-sixteen-bit"
  case gameCardHandheld = "game-card-handheld"
  case gameDisc = "game-disc"
  case gameCollectorBox = "game-collector-box"
  case digitalLibraryCard = "digital-library-card"
  case memoryCard = "memory-card"
  case saveFileCard = "save-file-card"
  case momentPhoto = "moment-photo"

  var id: String { rawValue }

  var displayName: String {
    rawValue
      .split(separator: "-")
      .map { word in
        switch word.lowercased() {
        case "pc", "nes", "snes": word.uppercased()
        default: word.capitalized
        }
      }
      .joined(separator: " ")
  }

  var fileName: String { "\(rawValue).webp" }
  var relativePath: String { "Collectibles/\(fileName)" }

  var pack: CollectibleAssetPack {
    switch self {
    case .controllerLate2010sSymmetric,
         .controllerEightBitRectangular,
         .controllerSixteenBitRounded,
         .controllerMid1990sDualGrip,
         .handheldMonochromeVertical,
         .handheldEarly2000sWide:
      .starter
    case .currentSculpturalHomeConsole,
         .currentBlackTowerConsole,
         .currentCompactDigitalConsole,
         .currentNextHybridConsole,
         .currentClassicHybridConsole,
         .currentHandheldGamingPC,
         .currentDesktopGamingPC,
         .currentGamingLaptop,
         .currentMobileGaming,
         .currentSpatialGamingHeadset:
      .current
    case .consoleEarly2000sBlack,
         .consoleLate2000sGlossy,
         .handheldMid2000sDisc,
         .handheldEarly2010sTouch:
      .playHistory
    case .consoleEarly2000sBold,
         .consoleMid2000sWhite,
         .consoleLate2010sFlat:
      .xboxHistory
    case .controllerThreeProng,
         .consoleCompactCube,
         .consoleMotionSlim,
         .consoleTabletHybrid,
         .handheldColorVertical,
         .handheldDualScreen,
         .handheldDualScreenDimensional:
      .nintendoHistory
    case .controllerSixButtonClassic,
         .controllerDiscEraRound,
         .consoleDiscEraWhite,
         .handheldLandscapeClassic,
         .consoleWoodgrainClassic,
         .consoleCompactCardBased,
         .consolePremiumCartridge,
         .arcadeCabinet:
      .segaAndArcade
    case .gameCaseTallOptical,
         .gameCaseSlimHybrid,
         .gameCartridgeEightBit,
         .gameCartridgeSixteenBit,
         .gameCardHandheld,
         .gameDisc,
         .gameCollectorBox,
         .digitalLibraryCard,
         .memoryCard,
         .saveFileCard,
         .momentPhoto:
      .gameMedia
    }
  }
}

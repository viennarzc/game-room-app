import Foundation
import ImageIO
import SwiftData
import Testing
@testable import Game_Room

@Suite("Game Room models")
struct GameRoomModelTests {
  @Test("A game and its moment persist together")
  func gameAndMomentRelationship() throws {
    let container = try ModelContainerFactory.makeInMemoryContainer()
    let context = ModelContext(container)
    let game = GameEntry(
      title: "Test Journey",
      platform: .nintendoSwitch,
      ownership: .physical,
      status: .playing
    )
    let moment = GameMoment(type: .started, note: "A good beginning", game: game)

    context.insert(game)
    context.insert(moment)
    game.moments?.append(moment)
    try context.save()

    let games = try context.fetch(FetchDescriptor<GameEntry>())
    #expect(games.count == 1)
    #expect(games.first?.sortedMoments.first?.note == "A good beginning")
    #expect(games.first?.ownership == .physical)
  }

  @Test("Deleting a game cascades to moments")
  func deleteCascade() throws {
    let container = try ModelContainerFactory.makeInMemoryContainer()
    let context = ModelContext(container)
    let game = GameEntry(
      title: "Temporary",
      platform: .pc,
      ownership: .digital,
      status: .backlog
    )
    let moment = GameMoment(type: .memory, game: game)
    context.insert(game)
    context.insert(moment)
    game.moments?.append(moment)
    try context.save()

    context.delete(game)
    try context.save()

    #expect(try context.fetch(FetchDescriptor<GameEntry>()).isEmpty)
    #expect(try context.fetch(FetchDescriptor<GameMoment>()).isEmpty)
  }
}

@Suite("Themes and reminders")
struct ThemeAndReminderTests {
  @Test("Every theme resolves every semantic role")
  func themeAssetsHaveStableNames() {
    for themeID in ThemeID.allCases {
      let theme = AppTheme(id: themeID)
      for role in ThemeColorRole.allCases {
        #expect(theme.assetName(for: role).hasPrefix("Theme"))
        #expect(theme.assetName(for: role).hasSuffix(role.rawValue))
      }
    }
  }

  @Test("Platform families suggest their matching theme")
  func platformThemeMapping() {
    #expect(GamingPlatform.playStation5.suggestedTheme == .midnightBlue)
    #expect(GamingPlatform.xboxSeries.suggestedTheme == .velocityGreen)
    #expect(GamingPlatform.nintendoSwitch.suggestedTheme == .joyRed)
    #expect(GamingPlatform.segaGenesis.suggestedTheme == .arcadeCobalt)
    #expect(GamingPlatform.pc.suggestedTheme == .desktopGraphite)
    #expect(GamingPlatform.nes.suggestedTheme == .eightBitClassic)
  }

  @Test("Every named platform resolves to a collectible asset")
  func platformCollectibleMapping() {
    let namedPlatforms = GamingPlatform.allCases.filter { $0 != .other }
    #expect(namedPlatforms.allSatisfy { $0.collectibleAsset != nil })
  }

  @Test("Collectible files have stable pack-relative WebP paths")
  func collectiblePaths() {
    #expect(CollectibleAssetID.controllerEightBitRectangular.pack == .starter)
    #expect(
      CollectibleAssetID.currentNextHybridConsole.relativePath
        == "Collectibles/current-next-hybrid-console.webp"
    )
    #expect(Set(CollectibleAssetPack.allCases.map(\.rawValue)).count == CollectibleAssetPack.allCases.count)
    #expect(Set(CollectibleAssetID.allCases.map(\.rawValue)).count == CollectibleAssetID.allCases.count)
    #expect(
      Set(CollectibleAssetPack.allCases.flatMap(\.assets))
        == Set(CollectibleAssetID.allCases)
    )
  }

  @Test("Every collectible has one transparent payload in its declared pack")
  func collectiblePayloadCoverage() throws {
    let repositoryURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    let payloadURL = repositoryURL
      .appendingPathComponent("AssetPacks/Payload/Collectibles", isDirectory: true)
    let manifestsURL = repositoryURL
      .appendingPathComponent("AssetPacks/Manifests", isDirectory: true)
    var selectors: [String] = []

    for pack in CollectibleAssetPack.allCases {
      let manifestURL = manifestsURL
        .appendingPathComponent(pack.rawValue)
        .appendingPathExtension("json")
      let manifest = try JSONDecoder().decode(
        TestAssetPackManifest.self,
        from: Data(contentsOf: manifestURL)
      )
      #expect(manifest.assetPackID == pack.rawValue)
      #expect(
        Set(manifest.fileSelectors.map(\.file))
          == Set(CollectibleAssetID.allCases.filter { $0.pack == pack }.map(\.relativePath))
      )
      selectors.append(contentsOf: manifest.fileSelectors.map(\.file))
    }

    let expectedPaths = Set(CollectibleAssetID.allCases.map(\.relativePath))
    #expect(Set(selectors) == expectedPaths)
    #expect(selectors.count == expectedPaths.count)

    for asset in CollectibleAssetID.allCases {
      let fileURL = payloadURL.appendingPathComponent(asset.fileName)
      let source = try #require(CGImageSourceCreateWithURL(fileURL as CFURL, nil))
      let properties = try #require(
        CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
      )
      #expect(properties[kCGImagePropertyHasAlpha] as? Bool == true)
      #expect((properties[kCGImagePropertyPixelWidth] as? Int ?? 0) <= 768)
      #expect((properties[kCGImagePropertyPixelHeight] as? Int ?? 0) <= 768)
    }
  }

  @Test("Game reminder identifiers are stable and distinct")
  func reminderIdentifiers() {
    let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    #expect(ReminderIdentifier.continuePlaying(gameID: id) != ReminderIdentifier.logMoment(gameID: id))
    #expect(ReminderIdentifier.weeklyGamingDay == "reminder.weekly-gaming-day")
  }

  @Test("Built-in artwork mirrors every collectible payload")
  func bundledCollectibleCoverage() throws {
    let repositoryURL = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent()
      .deletingLastPathComponent()
    let bundledArtworkURL = repositoryURL
      .appendingPathComponent("App/Resources/Collectibles", isDirectory: true)

    let bundledFiles = try FileManager.default.contentsOfDirectory(
      at: bundledArtworkURL,
      includingPropertiesForKeys: nil
    )
    let expectedFiles = Set(CollectibleAssetID.allCases.map(\.fileName))

    #expect(Set(bundledFiles.map(\.lastPathComponent)) == expectedFiles)
  }
}

private struct TestAssetPackManifest: Decodable {
  struct FileSelector: Decodable {
    let file: String
  }

  let assetPackID: String
  let fileSelectors: [FileSelector]
}

@Suite("Image pipeline")
struct ImagePipelineTests {
  @Test("Invalid image data is rejected")
  func invalidData() {
    #expect(ImagePipeline.downsizedJPEG(from: Data("not an image".utf8)) == nil)
  }
}

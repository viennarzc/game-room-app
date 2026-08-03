import Foundation
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

  @Test("Game reminder identifiers are stable and distinct")
  func reminderIdentifiers() {
    let id = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    #expect(ReminderIdentifier.continuePlaying(gameID: id) != ReminderIdentifier.logMoment(gameID: id))
    #expect(ReminderIdentifier.weeklyGamingDay == "reminder.weekly-gaming-day")
  }
}

@Suite("Image pipeline")
struct ImagePipelineTests {
  @Test("Invalid image data is rejected")
  func invalidData() {
    #expect(ImagePipeline.downsizedJPEG(from: Data("not an image".utf8)) == nil)
  }
}

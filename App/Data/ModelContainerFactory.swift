import Foundation
import SwiftData

enum ModelContainerFactory {
  static let cloudContainerIdentifier = "iCloud.com.vnrz.gameroom"

  static let schema = Schema([
    UserProfile.self,
    ConsoleProfile.self,
    GameEntry.self,
    GameMoment.self
  ])

  static func makeAppContainer() -> ModelContainer {
    if isRunningAutomatedTests {
      do {
        return try makeInMemoryContainer()
      } catch {
        fatalError("Unable to create the UI testing store: \(error.localizedDescription)")
      }
    }

    let cloudConfiguration = ModelConfiguration(
      "GameRoom",
      schema: schema,
      cloudKitDatabase: .private(cloudContainerIdentifier)
    )

    do {
      return try ModelContainer(for: schema, configurations: [cloudConfiguration])
    } catch {
      let localConfiguration = ModelConfiguration(
        "GameRoomLocal",
        schema: schema,
        cloudKitDatabase: .none
      )

      do {
        return try ModelContainer(for: schema, configurations: [localConfiguration])
      } catch {
        fatalError("Unable to create the Game Room data store: \(error.localizedDescription)")
      }
    }
  }

  private static var isRunningAutomatedTests: Bool {
    let processInfo = ProcessInfo.processInfo
    return processInfo.arguments.contains("--ui-testing")
      || processInfo.environment["XCTestConfigurationFilePath"] != nil
  }

  static func makeInMemoryContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(
      "GameRoomTests",
      schema: schema,
      isStoredInMemoryOnly: true,
      cloudKitDatabase: .none
    )
    return try ModelContainer(for: schema, configurations: [configuration])
  }
}

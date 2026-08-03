import SwiftData
import SwiftUI

@main
struct AppDefinition: App {
  private let modelContainer = ModelContainerFactory.makeAppContainer()

  @AppStorage("appearance-mode") private var appearanceRawValue = AppearanceMode.system.rawValue
  @AppStorage("theme-id") private var themeRawValue = ThemeID.midnightBlue.rawValue

  private var appearance: AppearanceMode {
    AppearanceMode(rawValue: appearanceRawValue) ?? .system
  }

  private var theme: AppTheme {
    AppTheme(id: ThemeID(rawValue: themeRawValue) ?? .midnightBlue)
  }

  var body: some Scene {
    WindowGroup {
      AppRootView()
        .environment(\.appTheme, theme)
        .preferredColorScheme(appearance.colorScheme)
        .tint(theme.color(.accent))
    }
    .modelContainer(modelContainer)
  }
}

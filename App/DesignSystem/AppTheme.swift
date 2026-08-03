import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable, Sendable {
  case midnightBlue
  case velocityGreen
  case joyRed
  case arcadeCobalt
  case desktopGraphite
  case eightBitClassic

  var id: String { rawValue }

  var name: LocalizedStringResource {
    switch self {
    case .midnightBlue: "Midnight Blue"
    case .velocityGreen: "Velocity Green"
    case .joyRed: "Joy Red"
    case .arcadeCobalt: "Arcade Cobalt"
    case .desktopGraphite: "Desktop Graphite"
    case .eightBitClassic: "8-Bit Classic"
    }
  }

  fileprivate var assetPrefix: String {
    switch self {
    case .midnightBlue: "ThemeMidnightBlue"
    case .velocityGreen: "ThemeVelocityGreen"
    case .joyRed: "ThemeJoyRed"
    case .arcadeCobalt: "ThemeArcadeCobalt"
    case .desktopGraphite: "ThemeDesktopGraphite"
    case .eightBitClassic: "ThemeEightBitClassic"
    }
  }
}

enum ThemeColorRole: String, CaseIterable, Sendable {
  case canvas = "Canvas"
  case surface = "Surface"
  case elevatedSurface = "ElevatedSurface"
  case accent = "Accent"
  case secondaryAccent = "SecondaryAccent"
  case textPrimary = "TextPrimary"
  case textSecondary = "TextSecondary"
  case onAccent = "OnAccent"
  case divider = "Divider"
}

enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
  case system
  case light
  case dark

  var id: String { rawValue }

  var name: LocalizedStringResource {
    switch self {
    case .system: "System"
    case .light: "Light"
    case .dark: "Dark"
    }
  }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
}

struct AppTheme: Equatable, Sendable {
  let id: ThemeID

  static let defaultTheme = AppTheme(id: .midnightBlue)

  func assetName(for role: ThemeColorRole) -> String {
    id.assetPrefix + role.rawValue
  }

  func color(_ role: ThemeColorRole) -> Color {
    Color(assetName(for: role))
  }
}

private struct AppThemeKey: EnvironmentKey {
  static let defaultValue = AppTheme.defaultTheme
}

extension EnvironmentValues {
  var appTheme: AppTheme {
    get { self[AppThemeKey.self] }
    set { self[AppThemeKey.self] = newValue }
  }
}

extension ShapeStyle where Self == Color {
  static func gameRoom(_ role: ThemeColorRole, theme: AppTheme) -> Color {
    theme.color(role)
  }
}

struct ThemeCanvasModifier: ViewModifier {
  @Environment(\.appTheme) private var theme

  func body(content: Content) -> some View {
    content
      .foregroundStyle(theme.color(.textPrimary))
      .background(theme.color(.canvas).ignoresSafeArea())
  }
}

extension View {
  func themeCanvas() -> some View {
    modifier(ThemeCanvasModifier())
  }
}

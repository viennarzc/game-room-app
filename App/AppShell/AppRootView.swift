import SwiftData
import SwiftUI

struct AppRootView: View {
  @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

  var body: some View {
    if profiles.first(where: \.onboardingCompleted) != nil {
      AppTabView()
    } else {
      OnboardingView()
    }
  }
}

struct AppTabView: View {
  var body: some View {
    Group {
      if #available(iOS 18.0, macOS 15.0, visionOS 2.0, *) {
        ModernAppTabView()
      } else {
        LegacyAppTabView()
      }
    }
  }
}

@available(iOS 18.0, macOS 15.0, visionOS 2.0, *)
private struct ModernAppTabView: View {
  var body: some View {
    TabView {
      Tab("Memory", systemImage: "sparkles") {
        MemoryHomeView()
      }

      Tab("Shelf", systemImage: "books.vertical.fill") {
        ShelfView()
      }

      Tab("Settings", systemImage: "gearshape.fill") {
        SettingsView()
      }
    }
  }
}

private struct LegacyAppTabView: View {
  var body: some View {
    TabView {
      MemoryHomeView()
        .tabItem {
          Label("Memory", systemImage: "sparkles")
        }

      ShelfView()
        .tabItem {
          Label("Shelf", systemImage: "books.vertical.fill")
        }

      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape.fill")
        }
    }
  }
}

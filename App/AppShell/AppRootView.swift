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

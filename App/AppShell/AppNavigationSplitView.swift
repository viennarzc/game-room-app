import SwiftUI

enum AppNavigationDestination: String, CaseIterable, Hashable, Identifiable {
  case memory
  case shelf
  case settings

  var id: Self { self }

  var title: LocalizedStringKey {
    switch self {
    case .memory:
      "Memory"
    case .shelf:
      "Shelf"
    case .settings:
      "Settings"
    }
  }

  var systemImage: String {
    switch self {
    case .memory:
      "sparkles"
    case .shelf:
      "books.vertical.fill"
    case .settings:
      "gearshape.fill"
    }
  }
}

struct AppNavigationSplitView: View {
  @State private var columnVisibility: NavigationSplitViewVisibility = .all
  @State private var selection: AppNavigationDestination? = .memory

  var body: some View {
    NavigationSplitView(columnVisibility: $columnVisibility) {
      AppNavigationSidebar(selection: $selection)
    } detail: {
      AppNavigationDetail(destination: selection ?? .memory)
        .id(selection)
    }
    .navigationSplitViewStyle(.balanced)
  }
}

private struct AppNavigationSidebar: View {
  @Binding var selection: AppNavigationDestination?

  var body: some View {
    List(selection: $selection) {
      ForEach(AppNavigationDestination.allCases) { destination in
        Label(destination.title, systemImage: destination.systemImage)
          .tag(Optional(destination))
      }
    }
    .listStyle(.sidebar)
    .navigationTitle("Game Room")
    .navigationSplitViewColumnWidth(min: 216, ideal: 248, max: 320)
    .accessibilityIdentifier("app-navigation-sidebar")
  }
}

private struct AppNavigationDetail: View {
  let destination: AppNavigationDestination

  var body: some View {
    switch destination {
    case .memory:
      MemoryHomeView()
    case .shelf:
      ShelfView()
    case .settings:
      SettingsView()
    }
  }
}

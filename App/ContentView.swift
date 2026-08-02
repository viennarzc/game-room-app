import SwiftUI

struct ContentView: View {
  @State private var library = GameLibrary()

  var body: some View {
    TabView {
      Tab("Memory", systemImage: "sparkles") {
        MemoryHomeView(library: library)
      }
      Tab("Shelf", systemImage: "books.vertical.fill") {
        ShelfView(library: library)
      }
    }
    .tint(Color(red: 0.13, green: 0.32, blue: 0.62))
  }
}

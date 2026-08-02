import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("memory-resurfacing") private var memoryResurfacing = true
  @AppStorage("reduce-decorative-motion") private var reduceDecorativeMotion = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          SettingsSection(title: "Privacy and storage", symbol: "lock.fill") {
            Text("Your journal is saved on this device. No public profile or account is required.")
          }
          SettingsSection(title: "Memory", symbol: "sparkles") {
            Toggle("Resurface older memories", isOn: $memoryResurfacing)
          }
          SettingsSection(title: "Appearance and motion", symbol: "circle.lefthalf.filled") {
            Toggle("Reduce decorative motion", isOn: $reduceDecorativeMotion)
          }
        }
        .padding(20)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
        }
      }
    }
  }
}

private struct SettingsSection<Content: View>: View {
  var title: String
  var symbol: String
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Label(title, systemImage: symbol).font(.headline)
      content
    }
    .padding(18)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
  }
}

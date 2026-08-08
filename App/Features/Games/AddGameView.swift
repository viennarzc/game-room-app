import PhotosUI
import SwiftData
import SwiftUI

struct AddGameView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  @FocusState private var isTitleFocused: Bool
  @State private var title = ""
  @State private var platform = GamingPlatform.switch2
  @State private var customPlatformName = ""
  @State private var ownership = OwnershipType.digital
  @State private var status = GameStatus.backlog
  @State private var objectStyle = GamingPlatform.switch2.defaultObjectStyle
  @State private var notes = ""
  @State private var photoItem: PhotosPickerItem?
  @State private var coverImageData: Data?

  private var trimmedTitle: String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var body: some View {
    let hasCover = coverImageData != nil
    NavigationStack {
      Form {
        Section {
          AddGamePreview(
            title: trimmedTitle,
            platform: platform,
            objectStyle: objectStyle,
            coverImageData: coverImageData,
            status: status
          )
        }

        Section("Game") {
          TextField("Title", text: $title)
            .focused($isTitleFocused)
          GamePlatformPicker(selection: $platform)
          if platform == .other {
            TextField("Custom platform", text: $customPlatformName)
          }
          Picker("Ownership", selection: $ownership) {
            ForEach(OwnershipType.allCases) { ownership in
              Label(ownership.rawValue, systemImage: ownership.symbol).tag(ownership)
            }
          }
        }

        Section("Shelf") {
          StatusSelectionRow(selection: $status)
          Picker("Object style", selection: $objectStyle) {
            ForEach(GameObjectStyle.allCases) { style in
              Text(style.rawValue).tag(style)
            }
          }
        }

        Section("Cover and notes") {
          PhotosPicker(selection: $photoItem, matching: .images) {
            Label(hasCover ? "Change Cover" : "Choose Cover", systemImage: "photo")
          }
          if coverImageData != nil {
            Button("Remove Cover", role: .destructive) {
              photoItem = nil
              coverImageData = nil
            }
          }
          TextField("Personal notes", text: $notes, axis: .vertical)
            .lineLimit(3...8)
        }
      }
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .navigationTitle("Add Game")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Add") { save() }
            .disabled(trimmedTitle.isEmpty)
        }
      }
      .onChange(of: platform) { _, newPlatform in
        objectStyle = newPlatform.defaultObjectStyle
      }
      .onChange(of: photoItem) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self) {
            coverImageData = ImagePipeline.downsizedJPEG(from: data)
          }
        }
      }
      .task { isTitleFocused = true }
    }
  }

  private func save() {
    let game = GameEntry(
      title: trimmedTitle,
      platform: platform,
      customPlatformName: platform == .other ? customPlatformName.nilIfBlank : nil,
      ownership: ownership,
      status: status,
      objectStyle: objectStyle,
      personalNotes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
      coverImageData: coverImageData
    )
    modelContext.insert(game)
    try? modelContext.save()
    dismiss()
  }
}

struct EditGameView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  let game: GameEntry
  @State private var title: String
  @State private var platform: GamingPlatform
  @State private var customPlatformName: String
  @State private var ownership: OwnershipType
  @State private var status: GameStatus
  @State private var objectStyle: GameObjectStyle
  @State private var notes: String
  @State private var photoItem: PhotosPickerItem?
  @State private var coverImageData: Data?

  init(game: GameEntry) {
    self.game = game
    _title = State(initialValue: game.title)
    _platform = State(initialValue: game.platform)
    _customPlatformName = State(initialValue: game.customPlatformName ?? "")
    _ownership = State(initialValue: game.ownership)
    _status = State(initialValue: game.status)
    _objectStyle = State(initialValue: game.objectStyle)
    _notes = State(initialValue: game.personalNotes)
    _coverImageData = State(initialValue: game.coverImageData)
  }

  var body: some View {
    let hasCover = coverImageData != nil
    NavigationStack {
      Form {
        Section("Game") {
          TextField("Title", text: $title)
          GamePlatformPicker(selection: $platform)
          if platform == .other {
            TextField("Custom platform", text: $customPlatformName)
          }
          Picker("Ownership", selection: $ownership) {
            ForEach(OwnershipType.allCases) { ownership in
              Label(ownership.rawValue, systemImage: ownership.symbol).tag(ownership)
            }
          }
          Picker("Status", selection: $status) {
            ForEach(GameStatus.allCases) { status in
              Label(status.rawValue, systemImage: status.symbol).tag(status)
            }
          }
          Picker("Object style", selection: $objectStyle) {
            ForEach(GameObjectStyle.allCases) { style in
              Text(style.rawValue).tag(style)
            }
          }
        }

        Section("Cover and notes") {
          PhotosPicker(selection: $photoItem, matching: .images) {
            Label(hasCover ? "Change Cover" : "Choose Cover", systemImage: "photo")
          }
          if coverImageData != nil {
            Button("Remove Cover", role: .destructive) {
              coverImageData = nil
              photoItem = nil
            }
          }
          TextField("Personal notes", text: $notes, axis: .vertical)
            .lineLimit(3...8)
        }
      }
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .navigationTitle("Edit Game")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
            .disabled(title.nilIfBlank == nil)
        }
      }
      .onChange(of: photoItem) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self) {
            coverImageData = ImagePipeline.downsizedJPEG(from: data)
          }
        }
      }
      .onChange(of: platform) { _, newPlatform in
        objectStyle = newPlatform.defaultObjectStyle
      }
    }
  }

  private func save() {
    guard let title = title.nilIfBlank else { return }
    game.title = title
    game.platform = platform
    game.customPlatformName = platform == .other ? customPlatformName.nilIfBlank : nil
    game.ownership = ownership
    game.status = status
    game.objectStyle = objectStyle
    game.personalNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    game.coverImageData = coverImageData
    game.updatedAt = .now
    try? modelContext.save()
    dismiss()
  }
}

private struct AddGamePreview: View {
  @Environment(\.appTheme) private var theme
  let title: String
  let platform: GamingPlatform
  let objectStyle: GameObjectStyle
  let coverImageData: Data?
  let status: GameStatus

  var body: some View {
    HStack(spacing: 18) {
      GameObjectPreview(
        title: title,
        platform: platform,
        style: objectStyle,
        coverImageData: coverImageData
      )
      .frame(width: 82, height: 112)
      VStack(alignment: .leading, spacing: 7) {
        Text("READY FOR YOUR SHELF")
          .font(.caption2.bold())
          .tracking(1)
          .foregroundStyle(theme.color(.textSecondary))
        Text(title.isEmpty ? "Your game" : title)
          .font(.headline)
          .lineLimit(2)
        Label(status.rawValue, systemImage: status.symbol)
          .font(.caption)
          .foregroundStyle(theme.color(.textSecondary))
      }
      Spacer()
    }
    .padding(.vertical, 8)
    .accessibilityElement(children: .combine)
  }
}

struct StatusSelectionRow: View {
  @Environment(\.appTheme) private var theme
  @Binding var selection: GameStatus

  var body: some View {
    ScrollView(.horizontal) {
      HStack(spacing: 8) {
        ForEach(GameStatus.allCases) { status in
          Button {
            selection = status
          } label: {
            Label(status.rawValue, systemImage: status.symbol)
              .font(.subheadline.weight(.medium))
              .foregroundStyle(selection == status ? theme.color(.onAccent) : theme.color(.textPrimary))
              .padding(.horizontal, 14)
              .frame(minHeight: 44)
              .background(selection == status ? theme.color(.accent) : theme.color(.elevatedSurface), in: Capsule())
          }
          .buttonStyle(.plain)
          .accessibilityAddTraits(selection == status ? .isSelected : [])
        }
      }
      .padding(.vertical, 3)
    }
    .scrollIndicators(.hidden)
  }
}

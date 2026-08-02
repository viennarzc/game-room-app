import PhotosUI
import SwiftUI

struct CaptureMomentView: View {
  @Environment(\.dismiss) private var dismiss
  var library: GameLibrary
  var onSaved: (() -> Void)?
  @State private var selectedGameID: String
  @State private var kind = MomentKind.memory
  @State private var note = ""
  @State private var photoItem: PhotosPickerItem?
  @State private var photoData: Data?
  @State private var mood = ""
  @State private var playedWith = ""
  @State private var duration = ""
  @State private var vibe = ""

  init(library: GameLibrary, gameID: String? = nil, onSaved: (() -> Void)? = nil) {
    self.library = library
    self.onSaved = onSaved
    let defaultID = gameID ?? library.nowPlaying.first?.id ?? library.games.first?.id ?? ""
    _selectedGameID = State(initialValue: defaultID)
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Picker("Game", selection: $selectedGameID) {
            ForEach(library.games) { game in
              Text(game.title).tag(game.id)
            }
          }
          .pickerStyle(.menu)
          MomentTypePicker(selection: $kind)
          VStack(alignment: .leading, spacing: 8) {
            Text(kind.prompt).font(.headline)
            TextField(kind.prompt, text: $note, axis: .vertical)
              .lineLimit(4...8)
              .textFieldStyle(.roundedBorder)
          }
          PhotosPicker(selection: $photoItem, matching: .images) {
            Label(photoData == nil ? "Add Photo" : "Photo Added", systemImage: photoData == nil ? "photo.badge.plus" : "checkmark")
              .frame(maxWidth: .infinity, minHeight: 44)
          }
          .buttonStyle(.bordered)
          DisclosureGroup("Add details") {
            MomentDetailsFields(mood: $mood, playedWith: $playedWith, duration: $duration, vibe: $vibe)
              .padding(.top, 8)
          }
        }
        .padding(20)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Capture Moment")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            let moment = GameMoment(
              id: UUID(),
              title: kind.rawValue,
              note: note.trimmingCharacters(in: .whitespacesAndNewlines),
              date: .now,
              kind: kind,
              photoData: photoData,
              mood: mood.nilIfBlank,
              playedWith: playedWith.nilIfBlank,
              durationMinutes: Int(duration),
              vibe: vibe.nilIfBlank
            )
            library.addMoment(moment, to: selectedGameID)
            onSaved?()
            dismiss()
          }
          .disabled(selectedGameID.isEmpty)
        }
      }
      .task(id: photoItem) {
        photoData = try? await photoItem?.loadTransferable(type: Data.self)
      }
    }
  }
}

struct MomentDetailsFields: View {
  @Binding var mood: String
  @Binding var playedWith: String
  @Binding var duration: String
  @Binding var vibe: String

  var body: some View {
    VStack(spacing: 12) {
      TextField("Mood", text: $mood)
      TextField("Played with", text: $playedWith)
      TextField("Duration in minutes", text: $duration)
        .keyboardType(.numberPad)
      TextField("Vibe or weather", text: $vibe)
    }
    .textFieldStyle(.roundedBorder)
  }
}

private struct MomentTypePicker: View {
  @Binding var selection: MomentKind

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Moment type").font(.headline)
      ScrollView(.horizontal) {
        HStack(spacing: 10) {
          ForEach(MomentKind.allCases, id: \.self) { kind in
            Button {
              selection = kind
            } label: {
              Label(kind.rawValue, systemImage: kind.symbol)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .foregroundStyle(selection == kind ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
                .background(selection == kind ? AnyShapeStyle(.tint) : AnyShapeStyle(.regularMaterial), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selection == kind ? .isSelected : [])
          }
        }
      }
      .scrollIndicators(.hidden)
    }
  }
}

private extension String {
  var nilIfBlank: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

import PhotosUI
import SwiftData
import SwiftUI

struct CaptureMomentView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  let game: GameEntry
  @State private var type = MomentType.session
  @State private var date = Date.now
  @State private var note = ""
  @State private var mood = ""
  @State private var playedWith = ""
  @State private var duration = ""
  @State private var weather = ""
  @State private var location = ""
  @State private var vibe = ""
  @State private var photoItem: PhotosPickerItem?
  @State private var photoData: Data?

  var body: some View {
    let hasPhoto = photoData != nil
    NavigationStack {
      Form {
        Section("Moment") {
          Picker("Type", selection: $type) {
            ForEach(MomentType.allCases) { type in
              Label(type.rawValue, systemImage: type.symbol).tag(type)
            }
          }
          DatePicker("Date", selection: $date)
          Text(type.prompt)
            .font(.subheadline)
            .foregroundStyle(theme.color(.textSecondary))
          TextField("Write a note", text: $note, axis: .vertical)
            .lineLimit(4...10)
        }

        Section("Photo") {
          PhotosPicker(selection: $photoItem, matching: .images) {
            Label(hasPhoto ? "Change Photo" : "Add Photo", systemImage: "photo")
          }
          if let photoData {
            StoredImageView(data: photoData, contentMode: .fit)
              .frame(maxHeight: 280)
              .clipShape(RoundedRectangle(cornerRadius: 14))
            Button("Remove Photo", role: .destructive) {
              self.photoData = nil
              photoItem = nil
            }
          }
        }

        MomentContextFields(
          mood: $mood,
          playedWith: $playedWith,
          duration: $duration,
          weather: $weather,
          location: $location,
          vibe: $vibe
        )
      }
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .navigationTitle("Capture Moment")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
        }
      }
      .onChange(of: photoItem) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self) {
            photoData = ImagePipeline.downsizedJPEG(from: data)
          }
        }
      }
    }
  }

  private func save() {
    let moment = GameMoment(
      type: type,
      note: note.trimmingCharacters(in: .whitespacesAndNewlines),
      date: date,
      mood: mood.nilIfBlank,
      playedWith: playedWith.nilIfBlank,
      durationMinutes: Int(duration),
      weatherLabel: weather.nilIfBlank,
      locationLabel: location.nilIfBlank,
      vibe: vibe.nilIfBlank,
      photoData: photoData,
      game: game
    )
    modelContext.insert(moment)
    game.moments?.append(moment)
    game.updatedAt = .now
    try? modelContext.save()
    dismiss()
  }
}

struct MomentContextFields: View {
  @Binding var mood: String
  @Binding var playedWith: String
  @Binding var duration: String
  @Binding var weather: String
  @Binding var location: String
  @Binding var vibe: String

  var body: some View {
    Section("Optional context") {
      TextField("Mood", text: $mood)
      TextField("Played with", text: $playedWith)
      TextField("Duration in minutes", text: $duration)
      #if os(iOS) || os(visionOS)
      .keyboardType(.numberPad)
      #endif
      TextField("Weather label", text: $weather)
      TextField("Location label", text: $location)
      TextField("Vibe", text: $vibe)
    }
  }
}

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct MomentDetailView: View {
  @Environment(\.dismiss) private var dismiss
  var momentID: UUID
  var library: GameLibrary
  @State private var isEditing = false
  @State private var isConfirmingDelete = false

  private var memory: MemoryMoment? {
    library.memoryMoment(id: momentID)
  }

  var body: some View {
    Group {
      if let memory {
        MomentDetailContent(memory: memory)
      } else {
        ContentUnavailableView("Memory not found", systemImage: "exclamationmark.triangle")
      }
    }
    .background(Color.galleryBackground)
    .navigationTitle("Memory")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Menu {
          Button("Edit", systemImage: "pencil") { isEditing = true }
          Button("Delete", systemImage: "trash", role: .destructive) { isConfirmingDelete = true }
        } label: {
          Label("Memory actions", systemImage: "ellipsis")
        }
      }
    }
    .sheet(isPresented: $isEditing) {
      if let memory {
        EditMomentView(moment: memory.moment, library: library)
      }
    }
    .confirmationDialog("Delete this memory?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
      Button("Delete Memory", role: .destructive) {
        library.deleteMoment(id: momentID)
        dismiss()
      }
    } message: {
      Text("This removes its note and photo from this device.")
    }
  }
}

private struct MomentDetailContent: View {
  var memory: MemoryMoment

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        MomentContextHeader(gameTitle: memory.game.title, platform: memory.game.platform, kind: memory.moment.kind, date: memory.moment.date)
        if let photoData = memory.moment.photoData, let image = platformImage(photoData) {
          Image(platformImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityLabel("Photo attached to this memory")
        }
        if !memory.moment.note.isEmpty {
          Text(memory.moment.note)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        MomentContextChips(moment: memory.moment)
      }
      .padding(20)
      .frame(maxWidth: 680)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

private struct MomentContextHeader: View {
  var gameTitle: String
  var platform: GamingPlatform
  var kind: MomentKind
  var date: Date

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label(kind.rawValue, systemImage: kind.symbol)
        .font(.headline)
        .foregroundStyle(.tint)
      Text(gameTitle).font(.largeTitle.bold())
      Text(platform.rawValue).font(.subheadline).foregroundStyle(.secondary)
      Text(date, format: .dateTime.weekday(.wide).month().day().year().hour().minute())
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}

private struct MomentContextChips: View {
  var moment: GameMoment

  var body: some View {
    FlowLayout(spacing: 8) {
      if let mood = moment.mood { DetailTag(symbol: "face.smiling", text: mood) }
      if let playedWith = moment.playedWith { DetailTag(symbol: "person.2", text: playedWith) }
      if let duration = moment.durationMinutes { DetailTag(symbol: "clock", text: "\(duration) min") }
      if let vibe = moment.vibe { DetailTag(symbol: "cloud.sun", text: vibe) }
    }
  }
}

private struct DetailTag: View {
  var symbol: String
  var text: String

  var body: some View {
    Label(text, systemImage: symbol)
      .font(.subheadline)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(.regularMaterial, in: Capsule())
  }
}

private struct EditMomentView: View {
  @Environment(\.dismiss) private var dismiss
  var moment: GameMoment
  var library: GameLibrary
  @State private var kind: MomentKind
  @State private var note: String
  @State private var mood: String
  @State private var playedWith: String
  @State private var duration: String
  @State private var vibe: String

  init(moment: GameMoment, library: GameLibrary) {
    self.moment = moment
    self.library = library
    _kind = State(initialValue: moment.kind)
    _note = State(initialValue: moment.note)
    _mood = State(initialValue: moment.mood ?? "")
    _playedWith = State(initialValue: moment.playedWith ?? "")
    _duration = State(initialValue: moment.durationMinutes.map(String.init) ?? "")
    _vibe = State(initialValue: moment.vibe ?? "")
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          Picker("Moment type", selection: $kind) {
            ForEach(MomentKind.allCases, id: \.self) { kind in
              Label(kind.rawValue, systemImage: kind.symbol).tag(kind)
            }
          }
          TextField("What do you want to remember?", text: $note, axis: .vertical)
            .lineLimit(4...8)
            .textFieldStyle(.roundedBorder)
          MomentDetailsFields(mood: $mood, playedWith: $playedWith, duration: $duration, vibe: $vibe)
        }
        .padding(20)
        .frame(maxWidth: 620)
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .background(Color.galleryBackground)
      .navigationTitle("Edit Memory")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            var updated = moment
            updated.kind = kind
            updated.title = kind.rawValue
            updated.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            updated.mood = mood.nilIfBlank
            updated.playedWith = playedWith.nilIfBlank
            updated.durationMinutes = Int(duration)
            updated.vibe = vibe.nilIfBlank
            library.updateMoment(updated)
            dismiss()
          }
        }
      }
    }
  }
}

private struct FlowLayout: Layout {
  var spacing: CGFloat

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let width = proposal.width ?? .greatestFiniteMagnitude
    var x: CGFloat = 0
    var y: CGFloat = 0
    var rowHeight: CGFloat = 0
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x + size.width > width, x > 0 {
        x = 0
        y += rowHeight + spacing
        rowHeight = 0
      }
      x += size.width + spacing
      rowHeight = max(rowHeight, size.height)
    }
    return CGSize(width: min(width, x), height: y + rowHeight)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var x = bounds.minX
    var y = bounds.minY
    var rowHeight: CGFloat = 0
    for subview in subviews {
      let size = subview.sizeThatFits(.unspecified)
      if x + size.width > bounds.maxX, x > bounds.minX {
        x = bounds.minX
        y += rowHeight + spacing
        rowHeight = 0
      }
      subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
      x += size.width + spacing
      rowHeight = max(rowHeight, size.height)
    }
  }
}

#if os(macOS)
private func platformImage(_ data: Data) -> NSImage? { NSImage(data: data) }
private extension Image {
  init(platformImage: NSImage) { self.init(nsImage: platformImage) }
}
#else
private func platformImage(_ data: Data) -> UIImage? { UIImage(data: data) }
private extension Image {
  init(platformImage: UIImage) { self.init(uiImage: platformImage) }
}
#endif

private extension String {
  var nilIfBlank: String? {
    let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}

import SwiftData
import SwiftUI

struct MomentDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme
  let moment: GameMoment

  @State private var isEditing = false
  @State private var isConfirmingDelete = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        MomentHeader(moment: moment)
        if let photoData = moment.photoData {
          StoredImageView(data: photoData, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .accessibilityLabel("Photo attached to this memory")
        }
        if !moment.note.isEmpty {
          Text(moment.note)
            .font(.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 18))
        }
        MomentContextChips(moment: moment)
      }
      .padding(20)
      .frame(maxWidth: 760)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .background(theme.color(.canvas))
    .navigationTitle(moment.title)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Menu("Actions", systemImage: "ellipsis.circle") {
          Button("Edit Memory", systemImage: "pencil") { isEditing = true }
          Button("Delete Memory", systemImage: "trash", role: .destructive) {
            isConfirmingDelete = true
          }
        }
      }
    }
    .sheet(isPresented: $isEditing) {
      EditMomentView(moment: moment)
    }
    .confirmationDialog("Delete this memory?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
      Button("Delete Memory", role: .destructive) {
        modelContext.delete(moment)
        try? modelContext.save()
        dismiss()
      }
    } message: {
      Text("This removes its note and photo from your journal.")
    }
  }
}

private struct MomentHeader: View {
  @Environment(\.appTheme) private var theme
  let moment: GameMoment

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label(moment.type.rawValue, systemImage: moment.type.symbol)
        .font(.headline)
        .foregroundStyle(theme.color(.accent))
      Text(moment.game?.title ?? "Game Memory").font(.largeTitle.bold())
      if let game = moment.game {
        Text(game.platformDisplayName)
          .font(.subheadline)
          .foregroundStyle(theme.color(.textSecondary))
      }
      Text(moment.date, format: .dateTime.weekday(.wide).month().day().year().hour().minute())
        .font(.subheadline)
        .foregroundStyle(theme.color(.textSecondary))
    }
  }
}

private struct MomentContextChips: View {
  let moment: GameMoment

  var body: some View {
    FlowLayout(spacing: 8) {
      if let mood = moment.mood { DetailTag(symbol: "face.smiling", text: mood) }
      if let playedWith = moment.playedWith { DetailTag(symbol: "person.2", text: playedWith) }
      if let duration = moment.durationMinutes { DetailTag(symbol: "clock", text: "\(duration) min") }
      if let weather = moment.weatherLabel { DetailTag(symbol: "cloud.sun", text: weather) }
      if let location = moment.locationLabel { DetailTag(symbol: "mappin", text: location) }
      if let vibe = moment.vibe { DetailTag(symbol: "waveform", text: vibe) }
    }
  }
}

private struct DetailTag: View {
  @Environment(\.appTheme) private var theme
  let symbol: String
  let text: String

  var body: some View {
    Label(text, systemImage: symbol)
      .font(.subheadline)
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(theme.color(.elevatedSurface), in: Capsule())
  }
}

private struct EditMomentView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme
  let moment: GameMoment

  @State private var type: MomentType
  @State private var date: Date
  @State private var note: String
  @State private var mood: String
  @State private var playedWith: String
  @State private var duration: String
  @State private var weather: String
  @State private var location: String
  @State private var vibe: String

  init(moment: GameMoment) {
    self.moment = moment
    _type = State(initialValue: moment.type)
    _date = State(initialValue: moment.date)
    _note = State(initialValue: moment.note)
    _mood = State(initialValue: moment.mood ?? "")
    _playedWith = State(initialValue: moment.playedWith ?? "")
    _duration = State(initialValue: moment.durationMinutes.map(String.init) ?? "")
    _weather = State(initialValue: moment.weatherLabel ?? "")
    _location = State(initialValue: moment.locationLabel ?? "")
    _vibe = State(initialValue: moment.vibe ?? "")
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Moment") {
          Picker("Type", selection: $type) {
            ForEach(MomentType.allCases) { type in
              Label(type.rawValue, systemImage: type.symbol).tag(type)
            }
          }
          DatePicker("Date", selection: $date)
          TextField("Note", text: $note, axis: .vertical)
            .lineLimit(4...10)
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
      .navigationTitle("Edit Memory")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save", action: save)
        }
      }
    }
  }

  private func save() {
    moment.type = type
    moment.date = date
    moment.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
    moment.mood = mood.nilIfBlank
    moment.playedWith = playedWith.nilIfBlank
    moment.durationMinutes = Int(duration)
    moment.weatherLabel = weather.nilIfBlank
    moment.locationLabel = location.nilIfBlank
    moment.vibe = vibe.nilIfBlank
    moment.updatedAt = .now
    try? modelContext.save()
    dismiss()
  }
}

private struct FlowLayout: Layout {
  let spacing: CGFloat

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

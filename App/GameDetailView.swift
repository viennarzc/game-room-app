import SwiftUI

struct GameDetailView: View {
  var gameID: String
  var library: GameLibrary
  var namespace: Namespace.ID
  @State private var isAddingMoment = false

  init(gameID: String, library: GameLibrary, namespace: Namespace.ID) {
    self.gameID = gameID
    self.library = library
    self.namespace = namespace
  }

  private var game: Game {
    library.game(id: gameID) ?? Game.samples[0]
  }

  private var status: Binding<GameStatus> {
    Binding(
      get: { game.status },
      set: { library.updateStatus($0, for: gameID) }
    )
  }

  private var notes: Binding<String> {
    Binding(
      get: { game.notes },
      set: { library.updateNotes($0, for: gameID) }
    )
  }

  var body: some View {
    ScrollView {
      VStack(spacing: 30) {
        GameHeroView(game: game)
        GameMetadataSection(platform: game.platform, status: status)
        MomentTimelineSection(moments: game.moments) {
          isAddingMoment = true
        }
        PersonalNotesSection(notes: notes)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 50)
      .frame(maxWidth: 760)
      .frame(maxWidth: .infinity)
    }
    .background(Color.galleryBackground)
    .navigationTitle("")
    .navigationBarTitleDisplayMode(.inline)
    .safeAreaInset(edge: .bottom) {
      Button("Capture Moment", systemImage: "square.and.pencil") {
        isAddingMoment = true
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .padding(.horizontal, 20)
      .padding(.vertical, 10)
      .frame(maxWidth: .infinity)
      .background(.bar)
    }
    .sheet(isPresented: $isAddingMoment) {
      CaptureMomentView(library: library, gameID: gameID)
    }
    .navigationDestination(for: UUID.self) { momentID in
      MomentDetailView(momentID: momentID, library: library)
    }
    .sensoryFeedback(.success, trigger: game.moments.count)
  }
}

private struct GameHeroView: View {
  var game: Game

  var body: some View {
    VStack(spacing: 18) {
      GameObjectView(game: game)
        .frame(width: 160, height: 210)
        .accessibilityHidden(true)
      VStack(spacing: 5) {
        Text(game.title).font(.largeTitle.bold()).multilineTextAlignment(.center)
        Text(game.subtitle).font(.subheadline).foregroundStyle(.secondary)
      }
    }
    .padding(.top, 22)
  }
}

private struct GameMetadataSection: View {
  var platform: GamingPlatform
  @Binding var status: GameStatus

  var body: some View {
    HStack(spacing: 12) {
      DetailChip(title: "Platform", value: platform.rawValue, symbol: "gamecontroller.fill")
      Picker("Status", selection: $status) {
        ForEach(GameStatus.allCases, id: \.self) { item in
          Label(item.rawValue, systemImage: item.symbol).tag(item)
        }
      }
      .pickerStyle(.menu)
      .buttonStyle(.bordered)
      .controlSize(.large)
      .accessibilityLabel("Game status")
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct DetailChip: View {
  var title: String
  var value: String
  var symbol: String

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: symbol).foregroundStyle(.tint)
      VStack(alignment: .leading, spacing: 1) {
        Text(title).font(.caption).foregroundStyle(.secondary)
        Text(value).font(.subheadline.weight(.semibold)).lineLimit(1)
      }
    }
    .padding(.horizontal, 14)
    .frame(minHeight: 48)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13))
  }
}

private struct PersonalNotesSection: View {
  @Binding var notes: String
  @State private var isExpanded = false

  var body: some View {
    DisclosureGroup(isExpanded: $isExpanded) {
      TextEditor(text: $notes)
        .scrollContentBackground(.hidden)
        .frame(minHeight: 90)
        .padding(12)
        .background(.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityLabel("Personal note")
        .padding(.top, 10)
    } label: {
      Label("Personal Note", systemImage: "note.text").font(.title3.bold())
    }
    .padding(16)
    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct MomentTimelineSection: View {
  var moments: [GameMoment]
  var addMoment: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      HStack {
        Label("Moments", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90").font(.title3.bold())
        Spacer()
        Button("Capture Moment", systemImage: "plus", action: addMoment)
          .buttonStyle(.borderedProminent)
      }
      if moments.isEmpty {
        ContentUnavailableView("No moments yet", systemImage: "sparkles", description: Text("Save a memory from this game."))
          .frame(maxWidth: .infinity)
      } else {
        VStack(spacing: 0) {
          ForEach(moments) { moment in
            NavigationLink(value: moment.id) {
              MomentRow(moment: moment)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct MomentRow: View {
  var moment: GameMoment

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      VStack(spacing: 0) {
        Image(systemName: moment.kind.symbol)
          .font(.caption.bold())
          .foregroundStyle(.white)
          .frame(width: 30, height: 30)
          .background(.tint, in: Circle())
        Rectangle().fill(.tint.opacity(0.25)).frame(width: 2, height: 55)
      }
      VStack(alignment: .leading, spacing: 4) {
        Text(moment.title).font(.headline)
        Text(moment.note).font(.subheadline).foregroundStyle(.secondary)
        Text(moment.date, format: .dateTime.month(.abbreviated).day().year())
          .font(.caption2).foregroundStyle(.tertiary)
      }
      Spacer()
      if let data = moment.photoData, let image = platformImage(data: data) {
        Image(platformImage: image)
          .resizable().scaledToFill().frame(width: 66, height: 66)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
    }
    .accessibilityElement(children: .combine)
  }

  #if os(macOS)
  private func platformImage(data: Data) -> NSImage? { NSImage(data: data) }
  #else
  private func platformImage(data: Data) -> UIImage? { UIImage(data: data) }
  #endif
}

#if os(macOS)
private extension Image {
  init(platformImage: NSImage) { self.init(nsImage: platformImage) }
}
#else
private extension Image {
  init(platformImage: UIImage) { self.init(uiImage: platformImage) }
}
#endif

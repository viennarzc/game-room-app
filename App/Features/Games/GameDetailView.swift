import SwiftData
import SwiftUI

struct GameDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  let game: GameEntry
  @State private var isEditing = false
  @State private var isCapturingMoment = false
  @State private var isSchedulingReminder = false
  @State private var isConfirmingDelete = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 26) {
        GameDetailHero(game: game)
        GameDetailMetadata(game: game)
        GameNotesSection(game: game)
        GameMomentTimeline(game: game) {
          isCapturingMoment = true
        }
      }
      .padding(20)
      .frame(maxWidth: 800)
      .frame(maxWidth: .infinity, alignment: .center)
    }
    .background(theme.color(.canvas))
    .navigationTitle(game.title)
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        Button("Capture Moment", systemImage: "square.and.pencil") {
          isCapturingMoment = true
        }
        Menu("More", systemImage: "ellipsis.circle") {
          Button("Edit Game", systemImage: "pencil") { isEditing = true }
          Button("Set Reminder", systemImage: "bell.badge") { isSchedulingReminder = true }
          Divider()
          Button("Delete Game", systemImage: "trash", role: .destructive) {
            isConfirmingDelete = true
          }
        }
      }
    }
    .sheet(isPresented: $isEditing) {
      EditGameView(game: game)
    }
    .sheet(isPresented: $isCapturingMoment) {
      CaptureMomentView(game: game)
    }
    .sheet(isPresented: $isSchedulingReminder) {
      GameReminderView(game: game)
    }
    .confirmationDialog("Delete \(game.title)?", isPresented: $isConfirmingDelete, titleVisibility: .visible) {
      Button("Delete Game", role: .destructive, action: deleteGame)
    } message: {
      Text("This also removes its notes, photos, moments, and pending reminders.")
    }
  }

  private func deleteGame() {
    NotificationScheduler.shared.cancelReminders(for: game.id)
    modelContext.delete(game)
    try? modelContext.save()
    dismiss()
  }
}

private struct GameDetailHero: View {
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  var body: some View {
    ViewThatFits(in: .horizontal) {
      HStack(alignment: .center, spacing: 28) {
        object
        details
      }
      VStack(alignment: .leading, spacing: 18) {
        object.frame(maxWidth: .infinity, alignment: .center)
        details
      }
    }
    .padding(22)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 24))
    .overlay {
      RoundedRectangle(cornerRadius: 24).stroke(theme.color(.divider), lineWidth: 1)
    }
  }

  private var object: some View {
    GameObjectView(game: game)
      .frame(width: 150, height: 208)
  }

  private var details: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(game.title)
        .font(.largeTitle.bold())
      Label(game.platformDisplayName, systemImage: "gamecontroller.fill")
        .foregroundStyle(theme.color(.textSecondary))
      Label(game.ownership.rawValue, systemImage: game.ownership.symbol)
        .foregroundStyle(theme.color(.textSecondary))
      Label(game.status.rawValue, systemImage: game.status.symbol)
        .font(.headline)
        .foregroundStyle(theme.color(.accent))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private struct GameDetailMetadata: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Shelf placement").font(.title2.bold())
      Picker("Status", selection: Binding(
        get: { game.status },
        set: {
          game.status = $0
          try? modelContext.save()
        }
      )) {
        ForEach(GameStatus.allCases) { status in
          Label(status.rawValue, systemImage: status.symbol).tag(status)
        }
      }
      .pickerStyle(.menu)
      .padding(14)
      .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 14))
    }
  }
}

private struct GameNotesSection: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Notes").font(.title2.bold())
      TextField(
        "What do you want to remember about this game?",
        text: Binding(
          get: { game.personalNotes },
          set: {
            game.personalNotes = $0
            game.updatedAt = .now
          }
        ),
        axis: .vertical
      )
      .lineLimit(4...10)
      .padding(16)
      .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 16))
      .onSubmit { try? modelContext.save() }
    }
  }
}

private struct GameMomentTimeline: View {
  @Environment(\.appTheme) private var theme
  let game: GameEntry
  let capture: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      HStack {
        Text("Moments").font(.title2.bold())
        Spacer()
        Button("Add", systemImage: "plus", action: capture)
      }

      if game.sortedMoments.isEmpty {
        ContentUnavailableView(
          "No moments yet",
          systemImage: "sparkles",
          description: Text("Capture a milestone, session, or memory from this game.")
        )
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 18))
      } else {
        LazyVStack(spacing: 12) {
          ForEach(game.sortedMoments) { moment in
            NavigationLink {
              MomentDetailView(moment: moment)
            } label: {
              GameMomentRow(moment: moment)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
}

private struct GameMomentRow: View {
  @Environment(\.appTheme) private var theme
  let moment: GameMoment

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: moment.type.symbol)
        .foregroundStyle(theme.color(.accent))
        .frame(width: 38, height: 38)
        .background(theme.color(.accent).opacity(0.12), in: Circle())
      VStack(alignment: .leading, spacing: 4) {
        Text(moment.title).font(.headline)
        Text(moment.date, format: .dateTime.month(.abbreviated).day().year())
          .font(.caption)
          .foregroundStyle(theme.color(.textSecondary))
        if !moment.note.isEmpty {
          Text(moment.note).lineLimit(3)
        }
      }
      Spacer()
      Image(systemName: "chevron.forward")
        .font(.caption)
        .foregroundStyle(theme.color(.textSecondary))
    }
    .padding(16)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16).stroke(theme.color(.divider), lineWidth: 1)
    }
  }
}

private enum GameReminderKind: String, CaseIterable, Identifiable {
  case continuePlaying = "Continue playing"
  case logMoment = "Log a moment"

  var id: String { rawValue }
}

private struct GameReminderView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.appTheme) private var theme
  let game: GameEntry

  @State private var kind = GameReminderKind.continuePlaying
  @State private var date = Date.now.addingTimeInterval(60 * 60 * 24)
  @State private var errorMessage: String?
  @State private var isScheduling = false

  var body: some View {
    NavigationStack {
      Form {
        Section("Reminder") {
          Picker("Type", selection: $kind) {
            ForEach(GameReminderKind.allCases) { kind in
              Text(kind.rawValue).tag(kind)
            }
          }
          DatePicker("Date and time", selection: $date, in: Date.now...)
        }
        if let errorMessage {
          Section {
            Text(errorMessage).foregroundStyle(.red)
          }
        }
      }
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .navigationTitle("Set Reminder")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Schedule") { schedule() }
            .disabled(isScheduling)
        }
      }
    }
  }

  private func schedule() {
    isScheduling = true
    errorMessage = nil
    Task {
      do {
        let scheduler = NotificationScheduler.shared
        let status = await scheduler.authorizationStatus()
        let authorized: Bool
        if status == .authorized {
          authorized = true
        } else {
          authorized = try await scheduler.requestAuthorization()
        }
        guard authorized else {
          await MainActor.run {
            errorMessage = "Notifications are disabled. Enable them in system settings to schedule this reminder."
            isScheduling = false
          }
          return
        }
        switch kind {
        case .continuePlaying:
          try await scheduler.scheduleContinuePlaying(for: game.id, gameTitle: game.title, at: date)
        case .logMoment:
          try await scheduler.scheduleLogMoment(for: game.id, gameTitle: game.title, at: date)
        }
        await MainActor.run { dismiss() }
      } catch {
        await MainActor.run {
          errorMessage = error.localizedDescription
          isScheduling = false
        }
      }
    }
  }
}

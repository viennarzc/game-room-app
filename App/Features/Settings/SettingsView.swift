import SwiftData
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

struct SettingsView: View {
  @Environment(\.appTheme) private var theme
  @Query(sort: \UserProfile.createdAt) private var profiles: [UserProfile]

  @AppStorage("appearance-mode") private var appearanceRawValue = AppearanceMode.system.rawValue
  @AppStorage("theme-id") private var themeRawValue = ThemeID.midnightBlue.rawValue
  @AppStorage("memory-resurfacing") private var memoryResurfacing = true
  @AppStorage("reduce-decorative-motion") private var reduceDecorativeMotion = false

  var body: some View {
    NavigationStack {
      Form {
        if let profile = profiles.first {
          Section("Gaming profile") {
            NavigationLink {
              ProfileSettingsView(profile: profile)
            } label: {
              LabeledContent("Nickname", value: profile.nickname ?? "Not set")
            }
            LabeledContent("Play style", value: profile.playStyle?.rawValue ?? "Not set")
            LabeledContent("Favorite platform", value: profile.favoritePlatform?.rawValue ?? "Not set")
          }
        }

        Section("Appearance") {
          Picker("Mode", selection: $appearanceRawValue) {
            ForEach(AppearanceMode.allCases) { appearance in
              Text(appearance.name).tag(appearance.rawValue)
            }
          }
          ThemeSelectionGrid(selectionRawValue: $themeRawValue)
          Toggle("Reduce decorative motion", isOn: $reduceDecorativeMotion)
        }

        Section("Memory") {
          Toggle("Resurface older memories", isOn: $memoryResurfacing)
        }

        ReminderSettingsSection()

        Section("Privacy and storage") {
          Label("Private by default", systemImage: "lock.shield.fill")
          Text("Your journal is stored locally and syncs through your private iCloud database when available. Game Room has no account, public profile, analytics, or external game catalog in this release.")
            .font(.footnote)
            .foregroundStyle(theme.color(.textSecondary))
          LabeledContent("iCloud container", value: ModelContainerFactory.cloudContainerIdentifier)
            .font(.footnote)
        }
      }
      .formStyle(.grouped)
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .navigationTitle("Settings")
    }
  }
}

private struct ProfileSettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  let profile: UserProfile
  @State private var nickname: String
  @State private var playStyle: PlayStyle?
  @State private var ownershipPreference: OwnershipType?
  @State private var favoritePlatform: GamingPlatform?
  @State private var ownedPlatforms: Set<GamingPlatform>

  init(profile: UserProfile) {
    self.profile = profile
    _nickname = State(initialValue: profile.nickname ?? "")
    _playStyle = State(initialValue: profile.playStyle)
    _ownershipPreference = State(initialValue: profile.ownershipPreference)
    _favoritePlatform = State(initialValue: profile.favoritePlatform)
    _ownedPlatforms = State(initialValue: Set((profile.consoles ?? []).map(\.platform)))
  }

  var body: some View {
    Form {
      Section("About you") {
        TextField("Nickname", text: $nickname)
        Picker("Play style", selection: $playStyle) {
          Text("Not set").tag(PlayStyle?.none)
          ForEach(PlayStyle.allCases) { style in
            Text(style.rawValue).tag(Optional(style))
          }
        }
        Picker("Collection preference", selection: $ownershipPreference) {
          Text("No preference").tag(OwnershipType?.none)
          ForEach(OwnershipType.allCases) { ownership in
            Text(ownership.rawValue).tag(Optional(ownership))
          }
        }
      }

      Section("Favorite platform") {
        Picker("Favorite", selection: $favoritePlatform) {
          Text("Not set").tag(GamingPlatform?.none)
          ForEach(GamingPlatform.allCases) { platform in
            Text(platform.rawValue).tag(Optional(platform))
          }
        }
      }

      Section("Platforms you own") {
        ForEach(GamingPlatform.allCases.filter { $0 != .other }) { platform in
          Toggle(platform.rawValue, isOn: Binding(
            get: { ownedPlatforms.contains(platform) },
            set: { isSelected in
              if isSelected { ownedPlatforms.insert(platform) }
              else { ownedPlatforms.remove(platform) }
            }
          ))
        }
      }
    }
    .formStyle(.grouped)
    .scrollContentBackground(.hidden)
    .background(theme.color(.canvas))
    .navigationTitle("Gaming Profile")
    .toolbar {
      ToolbarItem(placement: .confirmationAction) {
        Button("Save", action: save)
      }
    }
  }

  private func save() {
    profile.nickname = nickname.nilIfBlank
    profile.playStyle = playStyle
    profile.ownershipPreference = ownershipPreference

    for console in profile.consoles ?? [] {
      modelContext.delete(console)
    }

    var platforms = ownedPlatforms
    if let favoritePlatform { platforms.insert(favoritePlatform) }
    profile.consoles = platforms.map { platform in
      ConsoleProfile(platform: platform, isFavorite: platform == favoritePlatform, userProfile: profile)
    }
    try? modelContext.save()
    dismiss()
  }
}

private struct ReminderSettingsSection: View {
  @Environment(\.openURL) private var openURL
  @AppStorage("weekly-reminder-enabled") private var enabled = false
  @AppStorage("weekly-reminder-weekday") private var weekday = 7
  @AppStorage("weekly-reminder-hour") private var hour = 19
  @AppStorage("weekly-reminder-minute") private var minute = 0

  @State private var authorization = ReminderAuthorization.notDetermined
  @State private var errorMessage: String?

  private var reminderTime: Binding<Date> {
    Binding(
      get: {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
      },
      set: { newDate in
        let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
        hour = components.hour ?? 19
        minute = components.minute ?? 0
        if enabled { schedule() }
      }
    )
  }

  var body: some View {
    Section {
      Toggle("Weekly gaming day", isOn: Binding(
        get: { enabled },
        set: { newValue in
          enabled = newValue
          if newValue { authorizeAndSchedule() }
          else { NotificationScheduler.shared.cancelWeeklyGamingDay() }
        }
      ))

      if enabled {
        Picker("Day", selection: $weekday) {
          ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, day in
            Text(day).tag(index + 1)
          }
        }
        .onChange(of: weekday) { _, _ in schedule() }
        DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
      }

      if authorization == .denied {
        Button("Open Notification Settings", systemImage: "gear") {
          if let url = notificationSettingsURL { openURL(url) }
        }
      }

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundStyle(.red)
      }
    } header: {
      Text("Reminders")
    } footer: {
      Text("Continue Playing and Log a Moment reminders are available from each game.")
    }
    .task {
      authorization = await NotificationScheduler.shared.authorizationStatus()
    }
  }

  private func authorizeAndSchedule() {
    Task {
      do {
        let scheduler = NotificationScheduler.shared
        let current = await scheduler.authorizationStatus()
        let authorized: Bool
        if current == .authorized {
          authorized = true
        } else {
          authorized = try await scheduler.requestAuthorization()
        }
        await MainActor.run { authorization = authorized ? .authorized : .denied }
        guard authorized else {
          await MainActor.run { enabled = false }
          return
        }
        try await scheduler.scheduleWeeklyGamingDay(weekday: weekday, hour: hour, minute: minute)
      } catch {
        await MainActor.run {
          enabled = false
          errorMessage = error.localizedDescription
        }
      }
    }
  }

  private func schedule() {
    Task {
      do {
        try await NotificationScheduler.shared.scheduleWeeklyGamingDay(
          weekday: weekday,
          hour: hour,
          minute: minute
        )
        await MainActor.run { errorMessage = nil }
      } catch {
        await MainActor.run { errorMessage = error.localizedDescription }
      }
    }
  }

  private var notificationSettingsURL: URL? {
    #if canImport(UIKit)
    URL(string: UIApplication.openNotificationSettingsURLString)
    #elseif canImport(AppKit)
    URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension")
    #else
    nil
    #endif
  }
}

import SwiftData
import SwiftUI

struct OnboardingView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.appTheme) private var theme

  @AppStorage("theme-id") private var themeRawValue = ThemeID.midnightBlue.rawValue
  @AppStorage("weekly-reminder-enabled") private var weeklyReminderEnabled = false
  @AppStorage("weekly-reminder-weekday") private var weeklyReminderWeekday = 7
  @AppStorage("weekly-reminder-hour") private var weeklyReminderHour = 19
  @AppStorage("weekly-reminder-minute") private var weeklyReminderMinute = 0

  @State private var step = 0
  @State private var nickname = ""
  @State private var playStyle: PlayStyle?
  @State private var favoritePlatform: GamingPlatform?
  @State private var ownedPlatforms: Set<GamingPlatform> = []
  @State private var ownershipPreference: OwnershipType?
  @State private var wantsWeeklyReminder = false
  @State private var reminderDate = Calendar.current.date(
    bySettingHour: 19,
    minute: 0,
    second: 0,
    of: .now
  ) ?? .now
  @State private var isFinishing = false
  @State private var reminderError: String?

  private let lastStep = 4

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        OnboardingProgress(currentStep: step, totalSteps: lastStep + 1)
        OnboardingStepContent(
          step: step,
          nickname: $nickname,
          playStyle: $playStyle,
          favoritePlatform: $favoritePlatform,
          ownedPlatforms: $ownedPlatforms,
          ownershipPreference: $ownershipPreference,
          themeRawValue: $themeRawValue,
          wantsWeeklyReminder: $wantsWeeklyReminder,
          weeklyReminderWeekday: $weeklyReminderWeekday,
          reminderDate: $reminderDate
        )
      }
      .background(theme.color(.canvas).ignoresSafeArea())
      .safeAreaInset(edge: .bottom) {
        OnboardingActions(
          step: step,
          lastStep: lastStep,
          isFinishing: isFinishing,
          back: { withAnimation(.snappy) { step -= 1 } },
          next: advance
        )
      }
      .alert("Reminder unavailable", isPresented: Binding(
        get: { reminderError != nil },
        set: { if !$0 { reminderError = nil } }
      )) {
        Button("Continue") { finishOnboarding() }
      } message: {
        Text(reminderError ?? "You can enable reminders later in Settings.")
      }
    }
  }

  private func advance() {
    guard step == lastStep else {
      withAnimation(.snappy) { step += 1 }
      return
    }

    isFinishing = true
    if wantsWeeklyReminder {
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
              isFinishing = false
              reminderError = "Notification permission was not granted. You can finish setup and try again later."
            }
            return
          }

          let time = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
          try await scheduler.scheduleWeeklyGamingDay(
            weekday: weeklyReminderWeekday,
            hour: time.hour ?? 19,
            minute: time.minute ?? 0
          )
          await MainActor.run {
            weeklyReminderEnabled = true
            weeklyReminderHour = time.hour ?? 19
            weeklyReminderMinute = time.minute ?? 0
            finishOnboarding()
          }
        } catch {
          await MainActor.run {
            isFinishing = false
            reminderError = error.localizedDescription
          }
        }
      }
    } else {
      finishOnboarding()
    }
  }

  private func finishOnboarding() {
    let profile = UserProfile(
      nickname: nickname.nilIfBlank,
      playStyle: playStyle,
      ownershipPreference: ownershipPreference,
      onboardingCompleted: true
    )

    var selectedPlatforms = ownedPlatforms
    if let favoritePlatform { selectedPlatforms.insert(favoritePlatform) }

    profile.consoles = selectedPlatforms.map { platform in
      ConsoleProfile(
        platform: platform,
        isFavorite: platform == favoritePlatform,
        userProfile: profile
      )
    }

    modelContext.insert(profile)
    try? modelContext.save()
    UserDefaults.standard.removeObject(forKey: "game-room.library")
    isFinishing = false
  }
}

private struct OnboardingProgress: View {
  @Environment(\.appTheme) private var theme
  let currentStep: Int
  let totalSteps: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("GAME ROOM")
        .font(.caption.weight(.bold))
        .tracking(1.4)
        .foregroundStyle(theme.color(.textSecondary))
      ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
        .tint(theme.color(.accent))
        .accessibilityLabel("Onboarding progress")
        .accessibilityValue("Step \(currentStep + 1) of \(totalSteps)")
    }
    .padding(.horizontal, 24)
    .padding(.top, 20)
  }
}

private struct OnboardingStepContent: View {
  let step: Int
  @Binding var nickname: String
  @Binding var playStyle: PlayStyle?
  @Binding var favoritePlatform: GamingPlatform?
  @Binding var ownedPlatforms: Set<GamingPlatform>
  @Binding var ownershipPreference: OwnershipType?
  @Binding var themeRawValue: String
  @Binding var wantsWeeklyReminder: Bool
  @Binding var weeklyReminderWeekday: Int
  @Binding var reminderDate: Date

  var body: some View {
    switch step {
    case 0:
      WelcomeOnboardingStep()
    case 1:
      AboutYouOnboardingStep(nickname: $nickname, playStyle: $playStyle)
    case 2:
      PlatformsOnboardingStep(
        favoritePlatform: $favoritePlatform,
        ownedPlatforms: $ownedPlatforms
      )
    case 3:
      PreferencesOnboardingStep(
        ownershipPreference: $ownershipPreference,
        favoritePlatform: favoritePlatform,
        themeRawValue: $themeRawValue
      )
    default:
      ReminderOnboardingStep(
        enabled: $wantsWeeklyReminder,
        weekday: $weeklyReminderWeekday,
        reminderDate: $reminderDate
      )
    }
  }
}

private struct WelcomeOnboardingStep: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        CollectibleHeroCard(
          asset: .currentSculpturalHomeConsole,
          title: "A shelf for your gaming life",
          description: "Collect the games that matter and save the moments you want to remember."
        )
        PrivacyPromise()
      }
      .padding(24)
      .frame(maxWidth: 680, alignment: .leading)
      .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

private struct PrivacyPromise: View {
  @Environment(\.appTheme) private var theme

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Label("Private by default", systemImage: "lock.shield.fill")
        .font(.headline)
      Text("Your journal is stored on this device and syncs through your private iCloud database when available. Game Room has no account system, public profile, or analytics service.")
        .foregroundStyle(theme.color(.textSecondary))
    }
    .padding(20)
    .background(theme.color(.surface), in: RoundedRectangle(cornerRadius: 20))
  }
}

private struct AboutYouOnboardingStep: View {
  @Binding var nickname: String
  @Binding var playStyle: PlayStyle?

  var body: some View {
    Form {
      Section {
        TextField("Nickname (optional)", text: $nickname)
          .textContentType(.nickname)
        Picker("Play style", selection: $playStyle) {
          Text("Not set").tag(PlayStyle?.none)
          ForEach(PlayStyle.allCases) { style in
            Text(style.rawValue).tag(Optional(style))
          }
        }
      } header: {
        Text("About you")
      } footer: {
        Text("These answers only personalize your journal and can be changed later.")
      }
    }
    .onboardingFormStyle()
  }
}

private struct PlatformsOnboardingStep: View {
  @Binding var favoritePlatform: GamingPlatform?
  @Binding var ownedPlatforms: Set<GamingPlatform>

  var body: some View {
    Form {
      Section("Favorite platform") {
        FavoritePlatformPicker(selection: $favoritePlatform)
      }

      Section("Platforms you own") {
        ForEach(GamingPlatform.allCases.filter { $0 != .other }) { platform in
          Toggle(isOn: Binding(
            get: { ownedPlatforms.contains(platform) },
            set: { isSelected in
              if isSelected { ownedPlatforms.insert(platform) }
              else { ownedPlatforms.remove(platform) }
            }
          )) {
            Label(platform.rawValue, systemImage: platform.pickerSymbolName)
          }
        }
      }
    }
    .onboardingFormStyle()
  }
}

private struct PreferencesOnboardingStep: View {
  @Binding var ownershipPreference: OwnershipType?
  let favoritePlatform: GamingPlatform?
  @Binding var themeRawValue: String

  var body: some View {
    Form {
      Section("Collection preference") {
        Picker("Usually collect", selection: $ownershipPreference) {
          Text("No preference").tag(OwnershipType?.none)
          ForEach(OwnershipType.allCases) { ownership in
            Label(ownership.rawValue, systemImage: ownership.symbol).tag(Optional(ownership))
          }
        }
      }

      Section {
        ThemeSelectionGrid(selectionRawValue: $themeRawValue)
      } header: {
        Text("Choose a theme")
      } footer: {
        if let favoritePlatform {
          Text("We suggested a theme based on \(favoritePlatform.rawValue). You can choose any theme.")
        } else {
          Text("You can change themes at any time in Settings.")
        }
      }
    }
    .onboardingFormStyle()
    .onAppear {
      if let favoritePlatform {
        themeRawValue = favoritePlatform.suggestedTheme.rawValue
      }
    }
  }
}

private struct ReminderOnboardingStep: View {
  @Binding var enabled: Bool
  @Binding var weekday: Int
  @Binding var reminderDate: Date

  var body: some View {
    Form {
      Section {
        Toggle("Weekly reminder", isOn: $enabled)
        if enabled {
          Picker("Day", selection: $weekday) {
            ForEach(Array(Calendar.current.weekdaySymbols.enumerated()), id: \.offset) { index, day in
              Text(day).tag(index + 1)
            }
          }
          DatePicker("Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
        }
      } header: {
        Text("Gaming day")
      } footer: {
        Text("Notification permission is requested only if you turn this on. Other reminders can be scheduled from a game later.")
      }
    }
    .onboardingFormStyle()
  }
}

private struct OnboardingActions: View {
  let step: Int
  let lastStep: Int
  let isFinishing: Bool
  let back: () -> Void
  let next: () -> Void

  var body: some View {
    HStack {
      if step > 0 {
        Button("Back", action: back)
          .buttonStyle(.bordered)
      }
      Spacer()
      Button(action: next) {
        if isFinishing {
          ProgressView()
        } else {
          Text(step == lastStep ? "Enter Game Room" : "Continue")
        }
      }
      .buttonStyle(.borderedProminent)
      .disabled(isFinishing)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
    .background(.bar)
  }
}

struct ThemeSelectionGrid: View {
  @Binding var selectionRawValue: String

  private let columns = [GridItem(.adaptive(minimum: 136), spacing: 12)]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(ThemeID.allCases) { themeID in
        ThemeSelectionButton(
          themeID: themeID,
          isSelected: selectionRawValue == themeID.rawValue
        ) {
          selectionRawValue = themeID.rawValue
        }
      }
    }
    .padding(.vertical, 6)
  }
}

private struct ThemeSelectionButton: View {
  let themeID: ThemeID
  let isSelected: Bool
  let select: () -> Void

  var body: some View {
    let previewTheme = AppTheme(id: themeID)
    Button(action: select) {
      HStack(spacing: 10) {
        Circle()
          .fill(previewTheme.color(.accent))
          .frame(width: 24, height: 24)
          .overlay {
            Circle().stroke(previewTheme.color(.divider), lineWidth: 1)
          }
        Text(themeID.name)
          .font(.subheadline.weight(.medium))
          .lineLimit(1)
        Spacer(minLength: 0)
        if isSelected {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(previewTheme.color(.accent))
        }
      }
      .padding(12)
      .frame(maxWidth: .infinity, minHeight: 48)
      .background(previewTheme.color(.surface), in: RoundedRectangle(cornerRadius: 12))
      .overlay {
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? previewTheme.color(.accent) : previewTheme.color(.divider), lineWidth: isSelected ? 2 : 1)
      }
    }
    .buttonStyle(.plain)
    .accessibilityAddTraits(isSelected ? .isSelected : [])
  }
}

private extension View {
  func onboardingFormStyle() -> some View {
    modifier(OnboardingFormModifier())
  }
}

private struct OnboardingFormModifier: ViewModifier {
  @Environment(\.appTheme) private var theme

  func body(content: Content) -> some View {
    content
      .formStyle(.grouped)
      .scrollContentBackground(.hidden)
      .background(theme.color(.canvas))
      .frame(maxWidth: 760)
      .frame(maxWidth: .infinity)
  }
}

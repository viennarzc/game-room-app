import Foundation
import UserNotifications

enum ReminderAuthorization: Equatable, Sendable {
  case notDetermined
  case denied
  case authorized
}

protocol NotificationScheduling: Sendable {
  func authorizationStatus() async -> ReminderAuthorization
  func requestAuthorization() async throws -> Bool
  func scheduleWeeklyGamingDay(weekday: Int, hour: Int, minute: Int) async throws
  func scheduleContinuePlaying(for gameID: UUID, gameTitle: String, at date: Date) async throws
  func scheduleLogMoment(for gameID: UUID, gameTitle: String, at date: Date) async throws
  func cancelWeeklyGamingDay()
  func cancelReminders(for gameID: UUID)
}

enum ReminderIdentifier {
  static let weeklyGamingDay = "reminder.weekly-gaming-day"

  static func continuePlaying(gameID: UUID) -> String {
    "reminder.continue.\(gameID.uuidString)"
  }

  static func logMoment(gameID: UUID) -> String {
    "reminder.log.\(gameID.uuidString)"
  }
}

actor NotificationScheduler: NotificationScheduling {
  static let shared = NotificationScheduler()

  private let center = UNUserNotificationCenter.current()
  func authorizationStatus() async -> ReminderAuthorization {
    let settings = await center.notificationSettings()
    return switch settings.authorizationStatus {
    case .authorized, .provisional, .ephemeral: .authorized
    case .denied: .denied
    case .notDetermined: .notDetermined
    @unknown default: .notDetermined
    }
  }

  func requestAuthorization() async throws -> Bool {
    try await center.requestAuthorization(options: [.alert, .badge, .sound])
  }

  func scheduleWeeklyGamingDay(weekday: Int, hour: Int, minute: Int) async throws {
    center.removePendingNotificationRequests(withIdentifiers: [ReminderIdentifier.weeklyGamingDay])

    let content = UNMutableNotificationContent()
    content.title = "Your gaming day is here"
    content.body = "Pick something from your shelf and make a new memory."
    content.sound = .default

    var components = DateComponents()
    components.weekday = weekday
    components.hour = hour
    components.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    try await center.add(UNNotificationRequest(identifier: ReminderIdentifier.weeklyGamingDay, content: content, trigger: trigger))
  }

  func scheduleContinuePlaying(for gameID: UUID, gameTitle: String, at date: Date) async throws {
    try await scheduleOneShot(
      identifier: ReminderIdentifier.continuePlaying(gameID: gameID),
      title: "Continue \(gameTitle)",
      body: "Your game is waiting on the shelf.",
      date: date
    )
  }

  func scheduleLogMoment(for gameID: UUID, gameTitle: String, at date: Date) async throws {
    try await scheduleOneShot(
      identifier: ReminderIdentifier.logMoment(gameID: gameID),
      title: "Save a moment from \(gameTitle)",
      body: "Capture what made this play session worth remembering.",
      date: date
    )
  }

  nonisolated func cancelWeeklyGamingDay() {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ReminderIdentifier.weeklyGamingDay])
  }

  nonisolated func cancelReminders(for gameID: UUID) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [
      ReminderIdentifier.continuePlaying(gameID: gameID),
      ReminderIdentifier.logMoment(gameID: gameID)
    ])
  }

  private func scheduleOneShot(
    identifier: String,
    title: String,
    body: String,
    date: Date
  ) async throws {
    center.removePendingNotificationRequests(withIdentifiers: [identifier])

    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default

    let components = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )
    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    try await center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
  }
}

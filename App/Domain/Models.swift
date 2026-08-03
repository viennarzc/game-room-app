import Foundation
import SwiftData

@Model
final class UserProfile {
  var id: UUID = UUID()
  var nickname: String?
  var playStyleRawValue: String?
  var ownershipPreferenceRawValue: String?
  var onboardingCompleted: Bool = false
  var createdAt: Date = Date.now

  @Relationship(deleteRule: .cascade, inverse: \ConsoleProfile.userProfile)
  var consoles: [ConsoleProfile]? = []

  init(
    id: UUID = UUID(),
    nickname: String? = nil,
    playStyle: PlayStyle? = nil,
    ownershipPreference: OwnershipType? = nil,
    onboardingCompleted: Bool = false,
    createdAt: Date = .now
  ) {
    self.id = id
    self.nickname = nickname
    self.playStyleRawValue = playStyle?.rawValue
    self.ownershipPreferenceRawValue = ownershipPreference?.rawValue
    self.onboardingCompleted = onboardingCompleted
    self.createdAt = createdAt
  }

  var playStyle: PlayStyle? {
    get { playStyleRawValue.flatMap(PlayStyle.init(rawValue:)) }
    set { playStyleRawValue = newValue?.rawValue }
  }

  var ownershipPreference: OwnershipType? {
    get { ownershipPreferenceRawValue.flatMap(OwnershipType.init(rawValue:)) }
    set { ownershipPreferenceRawValue = newValue?.rawValue }
  }

  var favoritePlatform: GamingPlatform? {
    consoles?.first(where: \.isFavorite).flatMap { GamingPlatform(rawValue: $0.platformRawValue) }
  }
}

@Model
final class ConsoleProfile {
  var id: UUID = UUID()
  var platformRawValue: String = GamingPlatform.other.rawValue
  var customName: String?
  var isFavorite: Bool = false
  var userProfile: UserProfile?

  init(
    id: UUID = UUID(),
    platform: GamingPlatform,
    customName: String? = nil,
    isFavorite: Bool = false,
    userProfile: UserProfile? = nil
  ) {
    self.id = id
    self.platformRawValue = platform.rawValue
    self.customName = customName
    self.isFavorite = isFavorite
    self.userProfile = userProfile
  }

  var platform: GamingPlatform {
    get { GamingPlatform(rawValue: platformRawValue) ?? .other }
    set { platformRawValue = newValue.rawValue }
  }

  var displayName: String {
    customName?.nilIfBlank ?? platform.rawValue
  }
}

@Model
final class GameEntry {
  var id: UUID = UUID()
  var title: String = ""
  var platformRawValue: String = GamingPlatform.other.rawValue
  var customPlatformName: String?
  var ownershipRawValue: String = OwnershipType.digital.rawValue
  var statusRawValue: String = GameStatus.backlog.rawValue
  var objectStyleRawValue: String = GameObjectStyle.collectorCard.rawValue
  var personalNotes: String = ""
  var isFavorite: Bool = false
  var dateAdded: Date = Date.now
  var updatedAt: Date = Date.now

  @Attribute(.externalStorage)
  var coverImageData: Data?

  @Relationship(deleteRule: .cascade, inverse: \GameMoment.game)
  var moments: [GameMoment]? = []

  init(
    id: UUID = UUID(),
    title: String,
    platform: GamingPlatform,
    customPlatformName: String? = nil,
    ownership: OwnershipType,
    status: GameStatus,
    objectStyle: GameObjectStyle? = nil,
    personalNotes: String = "",
    coverImageData: Data? = nil,
    isFavorite: Bool = false,
    dateAdded: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    self.title = title
    self.platformRawValue = platform.rawValue
    self.customPlatformName = customPlatformName
    self.ownershipRawValue = ownership.rawValue
    self.statusRawValue = status.rawValue
    self.objectStyleRawValue = (objectStyle ?? platform.defaultObjectStyle).rawValue
    self.personalNotes = personalNotes
    self.coverImageData = coverImageData
    self.isFavorite = isFavorite
    self.dateAdded = dateAdded
    self.updatedAt = updatedAt
  }

  var platform: GamingPlatform {
    get { GamingPlatform(rawValue: platformRawValue) ?? .other }
    set {
      platformRawValue = newValue.rawValue
      updatedAt = .now
    }
  }

  var platformDisplayName: String {
    customPlatformName?.nilIfBlank ?? platform.rawValue
  }

  var ownership: OwnershipType {
    get { OwnershipType(rawValue: ownershipRawValue) ?? .digital }
    set {
      ownershipRawValue = newValue.rawValue
      updatedAt = .now
    }
  }

  var status: GameStatus {
    get { GameStatus(rawValue: statusRawValue) ?? .backlog }
    set {
      statusRawValue = newValue.rawValue
      updatedAt = .now
    }
  }

  var objectStyle: GameObjectStyle {
    get { GameObjectStyle(rawValue: objectStyleRawValue) ?? .collectorCard }
    set {
      objectStyleRawValue = newValue.rawValue
      updatedAt = .now
    }
  }

  var sortedMoments: [GameMoment] {
    (moments ?? []).sorted { $0.date > $1.date }
  }
}

@Model
final class GameMoment {
  var id: UUID = UUID()
  var typeRawValue: String = MomentType.memory.rawValue
  var title: String = ""
  var note: String = ""
  var date: Date = Date.now
  var mood: String?
  var playedWith: String?
  var durationMinutes: Int?
  var weatherLabel: String?
  var locationLabel: String?
  var vibe: String?
  var createdAt: Date = Date.now
  var updatedAt: Date = Date.now

  @Attribute(.externalStorage)
  var photoData: Data?

  var game: GameEntry?

  init(
    id: UUID = UUID(),
    type: MomentType,
    title: String? = nil,
    note: String = "",
    date: Date = .now,
    mood: String? = nil,
    playedWith: String? = nil,
    durationMinutes: Int? = nil,
    weatherLabel: String? = nil,
    locationLabel: String? = nil,
    vibe: String? = nil,
    photoData: Data? = nil,
    createdAt: Date = .now,
    updatedAt: Date = .now,
    game: GameEntry? = nil
  ) {
    self.id = id
    self.typeRawValue = type.rawValue
    self.title = title ?? type.rawValue
    self.note = note
    self.date = date
    self.mood = mood
    self.playedWith = playedWith
    self.durationMinutes = durationMinutes
    self.weatherLabel = weatherLabel
    self.locationLabel = locationLabel
    self.vibe = vibe
    self.photoData = photoData
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.game = game
  }

  var type: MomentType {
    get { MomentType(rawValue: typeRawValue) ?? .memory }
    set {
      typeRawValue = newValue.rawValue
      title = newValue.rawValue
      updatedAt = .now
    }
  }
}

struct MemoryMoment: Identifiable {
  let game: GameEntry
  let moment: GameMoment

  var id: UUID { moment.id }
}

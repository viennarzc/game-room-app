import SwiftUI
import WidgetKit

@main
struct GameRoomWidgetBundle: WidgetBundle {
  var body: some Widget {
    GameRoomWidget()
  }
}

struct GameRoomWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "app.bitrig.gameroom.continue", provider: GameRoomProvider()) { entry in
      VStack(alignment: .leading, spacing: 8) {
        Label("Continue playing", systemImage: "play.fill")
          .font(.caption.bold()).foregroundStyle(.secondary)
        Text("Ashen Crown").font(.headline)
        Text("PlayStation 5").font(.caption).foregroundStyle(.secondary)
        Spacer()
        Text("Your collection, one moment at a time.").font(.caption2)
      }
      .containerBackground(for: .widget) { Color(red: 0.94, green: 0.91, blue: 0.86) }
    }
    .configurationDisplayName("Continue Playing")
    .description("Keep your current game close by.")
  }
}

struct GameRoomProvider: TimelineProvider {
  func placeholder(in context: Context) -> GameRoomEntry { GameRoomEntry(date: .now) }
  func getSnapshot(in context: Context, completion: @escaping (GameRoomEntry) -> Void) { completion(GameRoomEntry(date: .now)) }
  func getTimeline(in context: Context, completion: @escaping (Timeline<GameRoomEntry>) -> Void) {
    completion(Timeline(entries: [GameRoomEntry(date: .now)], policy: .never))
  }
}

struct GameRoomEntry: TimelineEntry {
  var date: Date
}

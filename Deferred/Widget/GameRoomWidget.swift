// Deferred for a later release.
//
// The production widget will use an App Group-backed shared store and display
// real recent games or moments. It is intentionally excluded from active
// targets until that data-sharing contract is implemented.

import SwiftUI
import WidgetKit

struct DeferredGameRoomWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "DeferredGameRoomWidget", provider: DeferredProvider()) { _ in
      Label("Game Room", systemImage: "books.vertical.fill")
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("Game Room")
    .description("A future view into your gaming memories.")
  }
}

private struct DeferredEntry: TimelineEntry {
  let date: Date
}

private struct DeferredProvider: TimelineProvider {
  func placeholder(in context: Context) -> DeferredEntry { DeferredEntry(date: .now) }
  func getSnapshot(in context: Context, completion: @escaping (DeferredEntry) -> Void) {
    completion(DeferredEntry(date: .now))
  }
  func getTimeline(in context: Context, completion: @escaping (Timeline<DeferredEntry>) -> Void) {
    completion(Timeline(entries: [DeferredEntry(date: .now)], policy: .never))
  }
}

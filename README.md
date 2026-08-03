# Game Room

Game Room is a private, Apple-native gaming journal. It turns a backlog into a
tactile shelf of games and lightweight memories.

## Current release scope

- iPhone and iPad are the release platforms.
- macOS and visionOS are supported as local Debug smoke-build destinations.
- SwiftData is the source of truth and uses the private CloudKit container
  `iCloud.com.vnrz.gameroom` when the entitlement is available.
- Game entry is manual in v1. No account, analytics SDK, or external catalog is
  included.
- The previous UserDefaults demo library is intentionally not migrated.
- The widget is deferred until a real App Group data-sharing contract exists.

## Architecture

```text
App/
  AppShell/       App lifecycle and root navigation
  DesignSystem/   Environment theme and shared visual helpers
  Domain/         SwiftData models and stable domain values
  Data/           Model container configuration
  Services/       Notifications and image processing
  Features/       Onboarding, memory, shelf, games, moments, settings
```

Views use SwiftData queries and model bindings directly. Side effects that are
hard to test or tied to Apple services live behind narrow services.

## Local setup

1. Open `Game Room.xcodeproj` in Xcode 26 or newer.
2. Select a development team that owns `com.vnrz.gameroom`.
3. Register `iCloud.com.vnrz.gameroom` and enable CloudKit.
4. Initialize the development CloudKit schema before device sync testing.
5. Build Debug for iPhone, iPad, My Mac, or a visionOS simulator.

Without usable iCloud signing, the app falls back to its local SwiftData store.
Release builds are restricted to iOS destinations.

## Verification

- Run `Game RoomTests` for persistence, theme, reminder identifier, and image
  pipeline checks.
- Run `Game RoomUITests` on iOS for the clean onboarding path.
- Manually verify CloudKit synchronization on two signed-in devices before
  release.

## Deferred work

- Remote game search and cover metadata
- Widget/App Group data sharing
- Play Ritual
- Ratings, monetization, social features, automatic achievements, and imports

The catalog-provider study is in [Docs/Catalog-API-Study.md](Docs/Catalog-API-Study.md).

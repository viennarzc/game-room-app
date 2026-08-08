# Game Room

Game Room is a private, Apple-native gaming journal. It turns a backlog into a
tactile shelf of games and lightweight memories.

## Current release scope

- iPhone and iPad running iOS 17 or later are the release platforms.
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
  Services/       Notifications, image processing, and background assets
  Features/       Onboarding, memory, shelf, games, moments, settings
```

Views use SwiftData queries and model bindings directly. Side effects that are
hard to test or tied to Apple services live behind narrow services.

Collectible artwork ships as a compact local WebP library so it is visible
offline and on iOS 17. The same artwork is grouped into Apple-hosted Managed
Background Asset packs under `AssetPacks/`; supported systems can refresh a
collection without an app release. Native SF Symbols remain the final fallback
if image decoding is unavailable.

## Local setup

1. Open `Game Room.xcodeproj` in Xcode 26 or newer.
2. Select a development team that owns `com.vnrz.gameroom`.
3. Register `iCloud.com.vnrz.gameroom` and enable CloudKit.
4. Initialize the development CloudKit schema before device sync testing.
5. Build Debug for iPhone or iPad on iOS 17 or later; My Mac and visionOS
   remain local smoke-build destinations.
6. Register the App Group `group.com.vnrz.gameroom` for the app and its
   Background Assets extension.

Without usable iCloud signing, the app falls back to its local SwiftData store.
Release builds are restricted to iOS destinations.

## Verification

- Run `Game RoomTests` for persistence, theme, reminder identifier, and image
  pipeline checks.
- Run `Game RoomUITests` on iOS for the clean onboarding path.
- Package a local collectible update set with
  `tools/package_background_assets.sh collectibles-starter` and test it using
  Apple's Background Assets mock server.
- Manually verify CloudKit synchronization on two signed-in devices before
  release.

## Deferred work

- Remote game search and cover metadata
- Widget/App Group data sharing
- Play Ritual
- Ratings, monetization, social features, automatic achievements, and imports

The catalog-provider study is in [Docs/Catalog-API-Study.md](Docs/Catalog-API-Study.md).

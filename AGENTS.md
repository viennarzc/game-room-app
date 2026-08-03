# Repository Guidelines

## Project Structure & Module Organization

Game Room is a SwiftUI/SwiftData app. Production code lives in `App/`:
`AppShell/` contains lifecycle and root navigation; `Domain/` holds SwiftData
models and enums; `Data/` configures persistence; `Services/` contains focused
Apple-service integrations; `DesignSystem/` holds themes and reusable visuals;
and `Features/` groups screens by user flow. Theme colors belong in
`App/Assets.xcassets/ThemeColors/`, not Swift source. Unit tests are in
`Tests/`, UI tests in `UITests/`, deferred work in `Deferred/`, and supporting
decisions in `Docs/`.

`Project.json` is the project specification. When changing targets, source
groups, capabilities, or build settings, update it and regenerate the Xcode
project with `tools/regenerate_xcodeproj.rb`.

## Build, Test, and Development Commands

Open `Game Room.xcodeproj` in Xcode 26+ for interactive development. From the
repository root, these commands are useful:

```sh
xcodebuild -project 'Game Room.xcodeproj' -scheme 'Game Room' -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project 'Game Room.xcodeproj' -scheme 'Game Room' -destination 'platform=iOS Simulator,name=iPhone 17' test
ruby tools/regenerate_xcodeproj.rb
```

Use Debug on iOS, macOS, and visionOS for local smoke checks. Release builds
are intentionally limited to iOS and iPadOS.

## Coding Style & Naming Conventions

Use Swift 6 with two-space indentation, `UpperCamelCase` for types, and
`lowerCamelCase` for properties and functions. Keep views feature-scoped and
name them for their role, e.g. `Features/Games/AddGameView.swift`. Prefer
native SwiftUI controls and SwiftData queries; place platform differences in
small `#if os(...)` blocks beside shared views. Use `AppTheme` semantic roles
instead of hard-coded colors or opacity-based foregrounds.

## Testing Guidelines

Use Swift Testing (`@Suite`, `@Test`, `#expect`) for model, service, and theme
coverage in `Tests/`. Use XCTest for end-to-end paths in `UITests/`, naming
methods `test<Behavior>()`. New persistence behavior should cover CRUD and
relationships; reminder changes should cover stable identifiers. Run the iOS
test command above before submitting changes.

## Commit & Pull Request Guidelines

Follow the existing Conventional Commit style, such as
`feat(game-room): complete v1 journal experience`. Keep commits focused. Pull
requests should summarize user-visible changes, list verification performed,
link the related issue or Notion spec when available, and include screenshots
for visual SwiftUI changes. Do not commit signing certificates, team-specific
provisioning data, or provider credentials.

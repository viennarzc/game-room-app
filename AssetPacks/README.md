# Collectible Background Assets

Game Room keeps collectible artwork separate from the application binary. The
app contains a procedural SwiftUI fallback, while approved WebP artwork is
delivered in Apple-hosted Managed Background Assets packs.

The current catalog contains 49 transparent collectibles in seven on-demand
packs. Their optimized payload is about 1.5 MB in total, but none of those
bytes are embedded in the app bundle.

## Pack layout

| Pack | Contents | Policy |
| --- | --- | --- |
| `collectibles-starter` | Requested legacy controllers and handhelds | On demand |
| `collectibles-current` | Current home, hybrid, PC, mobile, and spatial systems | On demand |
| `collectibles-play-history` | Earlier Play-focused systems | On demand |
| `collectibles-xbox-history` | Earlier Xbox-focused systems | On demand |
| `collectibles-nintendo-history` | Earlier Nintendo home and handheld systems | On demand |
| `collectibles-sega-arcade` | Sega, Atari, Neo Geo, TurboGrafx, and arcade | On demand |
| `collectibles-game-media` | Cases, cartridges, discs, save cards, and photos | On demand |

`Content/` contains high-quality local working PNGs and is ignored by Git.
`Payload/` contains optimized 768 px transparent WebP files used by manifests.
`Archives/` contains generated `.aar` files and is also ignored.

## Build an asset pack

```sh
tools/package_background_assets.sh collectibles-starter
```

The script validates that every file named by the manifest exists, then runs
Apple's `ba-package` tool from `AssetPacks/Payload` so runtime paths remain
`Collectibles/<asset>.webp`.

Upload archives to App Store Connect independently of the app build. Use
Apple's local Background Assets mock server before TestFlight. A content view
can request only the pack it needs through `CollectibleAssetRepository`; the
existing procedural artwork remains a non-blocking fallback when a pack is
offline or unavailable.

## Visual contract

- 30-degree isometric view and consistent visual scale.
- Matte pastel plastic or paper with restrained contact shadows.
- Real alpha transparency; no painted checkerboard.
- No logos, brand marks, readable text, game art, or exact product copies.
- Maximum dimension 768 px; delivery format WebP with alpha.

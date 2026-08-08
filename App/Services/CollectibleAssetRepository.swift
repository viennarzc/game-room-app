import BackgroundAssets
import Foundation
import System

actor CollectibleAssetRepository {
  static let shared = CollectibleAssetRepository()

  private var memoryCache: [CollectibleAssetID: Data] = [:]

  func imageData(
    for asset: CollectibleAssetID,
    downloadIfNeeded: Bool = true
  ) async -> Data? {
    if let cached = memoryCache[asset] { return cached }

    #if !targetEnvironment(simulator)
    if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
      if let data = try? await managedAssetData(for: asset, downloadIfNeeded: downloadIfNeeded) {
        memoryCache[asset] = data
        return data
      }
    }
    #endif

    if let bundled = bundledData(for: asset) {
      memoryCache[asset] = bundled
      return bundled
    }

    return nil
  }

  func prefetch(_ pack: CollectibleAssetPack) async throws {
    #if !targetEnvironment(simulator)
    if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
      do {
        try await prefetchManagedAssetPack(pack)
        return
      } catch {
        // Built-in art keeps the gallery available when the managed pack has
        // not been hosted yet or the device is offline.
      }
    }
    #endif

    guard pack.assets.allSatisfy({ bundledData(for: $0) != nil }) else {
      throw CollectibleAssetRepositoryError.artworkUnavailable
    }
  }

  func remove(_ pack: CollectibleAssetPack) async throws {
    #if !targetEnvironment(simulator)
    if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
      try await AssetPackManager.shared.remove(assetPackWithID: pack.rawValue)
    }
    #endif
    memoryCache = memoryCache.filter { $0.key.pack != pack }
  }

  private func bundledData(for asset: CollectibleAssetID) -> Data? {
    let url = Bundle.main.url(
      forResource: asset.rawValue,
      withExtension: "webp",
      subdirectory: "Collectibles"
    ) ?? Bundle.main.url(forResource: asset.rawValue, withExtension: "webp")
    guard let url else { return nil }
    return try? Data(contentsOf: url, options: .mappedIfSafe)
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  private func managedAssetData(
    for asset: CollectibleAssetID,
    downloadIfNeeded: Bool
  ) async throws -> Data {
    let manager = AssetPackManager.shared
    if downloadIfNeeded {
      let pack = try await manager.assetPack(withID: asset.pack.rawValue)
      if #available(iOS 26.4, macOS 26.4, visionOS 26.4, *) {
        try await manager.ensureLocalAvailability(of: pack, requireLatestVersion: false)
      } else {
        try await manager.ensureLocalAvailability(of: pack)
      }
    }
    return try manager.contents(
      at: FilePath(asset.relativePath),
      searchingInAssetPackWithID: asset.pack.rawValue
    )
  }

  @available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
  private func prefetchManagedAssetPack(_ pack: CollectibleAssetPack) async throws {
    let manager = AssetPackManager.shared
    let assetPack = try await manager.assetPack(withID: pack.rawValue)
    if #available(iOS 26.4, macOS 26.4, visionOS 26.4, *) {
      try await manager.ensureLocalAvailability(of: assetPack, requireLatestVersion: false)
    } else {
      try await manager.ensureLocalAvailability(of: assetPack)
    }
  }
}

private enum CollectibleAssetRepositoryError: Error {
  case artworkUnavailable
}

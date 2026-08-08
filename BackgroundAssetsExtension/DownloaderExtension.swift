import BackgroundAssets
import ExtensionFoundation
import StoreKit

@main
struct DownloaderExtension: StoreDownloaderExtension {
  // Download policies live in the pack manifests. No additional filtering is
  // needed here because every Game Room collectible pack is on demand.
}

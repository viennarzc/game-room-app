#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: tools/package_background_assets.sh <pack-id>" >&2
  exit 64
fi

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
pack_id=$1
manifest="$repository_root/AssetPacks/Manifests/$pack_id.json"
archive_directory="$repository_root/AssetPacks/Archives"

if [ ! -f "$manifest" ]; then
  echo "Missing manifest: $manifest" >&2
  exit 66
fi

mkdir -p "$archive_directory"
cd "$repository_root/AssetPacks/Payload"
xcrun ba-package package "$manifest" --output-path "$archive_directory/$pack_id.aar"

echo "Created AssetPacks/Archives/$pack_id.aar"

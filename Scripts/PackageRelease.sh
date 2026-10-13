#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

mode="${1:-signed}"
app="${2:-build/DerivedData/Build/Products/Release/Dozer.app}"
case "$mode" in
    local) ;;
    signed)
        : "${SIGNING_IDENTITY:?Set SIGNING_IDENTITY to your Developer ID Application certificate name}"
        : "${NOTARY_PROFILE:?Set NOTARY_PROFILE to your notarytool Keychain profile name}"
        if [[ "$SIGNING_IDENTITY" != "Developer ID Application: "* ]]; then
            echo "Public releases require a Developer ID Application identity." >&2
            exit 1
        fi
        if [[ -n "$(git status --porcelain)" ]]; then
            echo "Commit all changes before building a public release so its source matches the binary." >&2
            exit 1
        fi
        make build
        ;;
    *) echo "Usage: $0 [local|signed] [path/to/Dozer.app]" >&2; exit 1 ;;
esac

version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
release_dir="Releases/$version/$mode"
mkdir -p "$release_dir"
stage=$(mktemp -d "${TMPDIR:-/tmp}/dozer-release.XXXXXX")
trap 'rm -rf "$stage"' EXIT
ditto "$app" "$stage/Dozer.app"
cp LICENSE "$stage/LICENSE"
cp Dozer/Other/SOURCE.txt "$stage/SOURCE.txt"

if [[ "$mode" == signed ]]; then
    codesign --force --sign "$SIGNING_IDENTITY" --options runtime --timestamp "$stage/Dozer.app"
    codesign --verify --deep --strict --verbose=2 "$stage/Dozer.app"
    ditto -c -k --sequesterRsrc --keepParent "$stage/Dozer.app" "$stage/notarization.zip"
    xcrun notarytool submit "$stage/notarization.zip" --keychain-profile "$NOTARY_PROFILE" --wait
    xcrun stapler staple "$stage/Dozer.app"
    xcrun stapler validate "$stage/Dozer.app"
    spctl --assess --type execute --verbose=2 "$stage/Dozer.app"
    rm "$stage/notarization.zip"
    archive="Dozer-$version-macos-arm64.zip"
    cat > "$stage/INSTALL.txt" <<'EOF'
Requires macOS 13 or later and an Apple Silicon Mac (M1 or later).
Quit any older version of Dozer. Drag Dozer.app to Applications, then open it.
Hold Command and drag menu bar icons to the left of the second Dozer dot.
Click a Dozer dot to hide/show them; right-click a dot to open Settings.
This is an independent, free fork of Dozer, originally created by Mortennn.
Source and support: https://github.com/disparta/Dozer
EOF
else
    archive="Dozer-$version-macos-arm64-local.zip"
    echo "Local development build. Ad hoc signed; NOT notarized. Do not publish as a signed release." > "$stage/INSTALL.txt"
fi

ditto -c -k --sequesterRsrc "$stage" "$release_dir/$archive"
(cd "$release_dir" && shasum -a 256 "$archive" > "$archive.sha256")
echo "Package: $release_dir/$archive"

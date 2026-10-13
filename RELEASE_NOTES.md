Dozer is free to download and use. This is an independent community fork of
[Mortennn/Dozer](https://github.com/Mortennn/Dozer), maintained by Musa Rikhotso.

- Native Apple Silicon build; Rosetta is not required.
- Replaces the original Carthage frameworks with native macOS implementations.
- Uses macOS's current launch-at-login API.
- Includes settings, keyboard shortcuts, and menu bar hide/show controls.
- Updates are installed manually from this fork's Releases page.

Requires **macOS 13 or later and an Apple Silicon Mac (M1 or later)**.
Intel Macs are not supported by this build. Settings from the original app
are not automatically migrated.

Download `Dozer-4.2.1-macos-arm64.zip`, unzip it, quit any older Dozer app, then
drag `Dozer.app` into Applications and open it. Hold Command to rearrange menu
bar icons; right-click a Dozer dot for Settings.

The public package is Developer ID signed and notarized by Apple. The companion
`.sha256` file lets you verify the download with `shasum -a 256 -c <filename>`.

Licensed under MPL 2.0. The corresponding source is available in this release's
source archives and at https://github.com/disparta/Dozer/tree/v4.2.1.

<p align="center">
	<img width="200" height="200" src="Stuff/AppIcon.png" alt="Dozer icon">
</p>
<p align="center">Hide menu bar icons to give your Mac a cleaner look.</p>
<p align="center">
	<a href="https://github.com/disparta/Dozer/releases">
		<img src="https://img.shields.io/badge/releases-download-brightgreen.svg" alt="releases">
	</a>
	<a href="https://img.shields.io/badge/platform-macOS-lightgrey.svg">
 		<img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg" alt="platform">
	</a>
	<a href="https://github.com/disparta/Dozer">
		<img src="https://img.shields.io/badge/requirements-macOS%2013%2B%20%C2%B7%20Apple%20Silicon-lightgrey.svg" alt="macOS 13 or later, Apple Silicon">
	</a>
	<a href="https://opensource.org/licenses/MPL-2.0">
 		<img src="https://img.shields.io/badge/License-MPL%202.0-orange.svg" alt="license">
	</a>
</p>
<p align="center">
	<img height="100" src="Stuff/demo.gif" alt="demo">
</p>

This is an independent community fork of [Mortennn/Dozer](https://github.com/Mortennn/Dozer),
maintained by [Musa Rikhotso](https://github.com/disparta). It is free to download,
use, and modify under the MPL 2.0 license.

## Download and install

The first signed and notarized release is being prepared. Downloads will appear
on this fork's [Releases page](https://github.com/disparta/Dozer/releases).

When available, download `Dozer-<version>-macos-arm64.zip`, unzip it, and drag
`Dozer.app` into Applications. Quit any older version of Dozer before opening
this fork. You need macOS 13 or later and an Apple Silicon Mac (M1 or later).
Xcode and Homebrew are only needed to build from source.

Updates are installed manually from the Releases page. This fork has its own
app identifier, so settings from the original app are not automatically migrated.

## Build a native Apple Silicon app

This maintained fork builds Dozer directly for Apple Silicon and no longer
depends on the abandoned Carthage frameworks used by the original release.
It requires macOS 13 or newer, Apple Silicon, and Xcode 26 or newer.

```shell
brew install xcodegen
make build
open build/DerivedData/Build/Products/Release/Dozer.app
```

The resulting executable is an arm64 binary and does not use Rosetta. To work
in Xcode instead, run `make open`.

`make package` creates a local development ZIP with an ad hoc signature. Public
downloads use `make release` with Developer ID signing and Apple notarization;
see [RELEASING.md](RELEASING.md).

## ⚫️ Dozer Icons

There are 2 or 3, numbered from right to left:

1. this can be positioned anywhere you prefer, it is only a point of interaction
2. this and everything to its left will be hidden/shown by clicking any Dozer icon
3. (Optional) the "remove" icon and everything to its left will be hidden/shown by option-clicking any Dozer icon

## 👨‍💻 Usage

* Move the icons you want to hide until clicked to the left of the second Dozer icon
* Move the icons you want to hide until option-clicked to the left of the third Dozer icon

**N.B. hold command (`⌘`) then drag to move the menu bar icons.**

## 👇 Interactions
* Left-click one of the Dozer icons to hide/show the first group of menu bar icons
* Option-Left-click one of the Dozer icons to show the second group of menu bar icons (optional)
* Right-click one of the Dozer icons to open the settings

<!-- GIF is commented out until it is redone -->
<!-- **Checkout [this GIF](https://raw.githubusercontent.com/Mortennn/Dozer/master/Stuff/demo.gif) to watch Dozer in action.** -->

## 📄 Requirements

macOS 13 or newer and Apple Silicon. Intel Macs are not supported by this build.

## License and origin

Dozer was originally created by Mortennn and is distributed under the Mozilla
Public License 2.0. This fork preserves the original notices and license while
modernizing the app for current macOS releases.

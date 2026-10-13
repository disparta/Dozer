# Changelog

## Version 4.2.1 (community fork, release in preparation)

- Native Apple Silicon build targeting macOS 13 or newer.
- Replace Carthage frameworks with native preferences, settings, keyboard
  shortcuts, and launch-at-login support.
- Update menu bar window detection for current macOS versions.
- Add release packaging with Developer ID signing, notarization, and checksums.
- Include the MPL license and source instructions in the app and download.
- Use manual updates through this fork's GitHub Releases page.

## Version 4.2.0
New features:
* Configure amount of seconds to hide the icons after #104. @blakedgordon
* Resize icons and padding capability added #101. @blakedgordon

Fixed:
* Fix both dozer icons from being hidden #105. @blakedgordon

Thank you @blakedgordon for the contributions🙌

## Version 4.1.0
New features:
* Hide status bar icons at launch #78. @aonez

Fixed:
* Reduce CPU usage when "Hide status bar icons after 10 seconds" is checked #78. @aonez

Thank you @aonez for the contributions🙌

## Version 4
New features:
* ”Remove”-icon. Additional icon to hide/show icons with `option+click`
* Auto-hide status bar icons #22
* ”No Icon”-mode. Hide/show only using keyboard shortcut

Other:
* Improved UI in preferences

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa

final class General: NSViewController, PreferencePane {
    let preferencePaneIdentifier = PreferencePaneIdentifier.general
    let preferencePaneTitle: String = "General"
    let toolbarItemIcon = NSImage(named: NSImage.preferencesGeneralName)!

    override var nibName: NSNib.Name? { "General" }

    fileprivate var userShortcut: KeyboardShortcut?

    @IBOutlet private var LaunchAtLoginCheckbox: NSButton!
    @IBOutlet private var CheckForUpdatesCheckbox: NSButton!
    @IBOutlet private var HideStatusBarIconsAtLaunchCheckbox: NSButton!
    @IBOutlet private var HideStatusBarIconsAfterDelayCheckbox: NSButton!
    @IBOutlet private var HideStatusBarIconsSecondsPopUpButton: NSPopUpButton!
    @IBOutlet private var HideBothDozerIconsCheckbox: NSButton!
    @IBOutlet private var EnableRemoveDozerIconCheckbox: NSButton!
    @IBOutlet private var ShowIconAndMenuCheckbox: NSButton!
    @IBOutlet private var FontSizePopUpButton: NSPopUpButton!
    @IBOutlet private var ButtonPaddingPopUpButton: NSPopUpButton!
    @IBOutlet private var ToggleMenuItemsView: ShortcutRecorderView!

    override func viewDidLoad() {
        super.viewDidLoad()

        LaunchAtLoginCheckbox.focusRingType = .none

        LaunchAtLoginCheckbox.isChecked = LaunchAtLoginController.isEnabled
        CheckForUpdatesCheckbox.isHidden = true

        HideStatusBarIconsAtLaunchCheckbox.isChecked = Settings.hideAtLaunchEnabled
        HideStatusBarIconsAfterDelayCheckbox.isChecked = Settings.hideAfterDelayEnabled
        HideBothDozerIconsCheckbox.isChecked = Settings.noIconMode
        EnableRemoveDozerIconCheckbox.isChecked = Settings.removeDozerIconEnabled
        ShowIconAndMenuCheckbox.isChecked = Settings.showIconAndMenuEnabled
        HideStatusBarIconsSecondsPopUpButton.selectItem(withTitle: "\(Int(Settings.hideAfterDelay)) seconds")
        FontSizePopUpButton.selectItem(withTitle: "\(Settings.iconSize) px")
        ButtonPaddingPopUpButton.selectItem(withTitle: "\(Int(Settings.buttonPadding)) px")

        configureEnabledNoIconCheckbox()

        ToggleMenuItemsView.shortcutValueChange = { _ -> Void in
            self.userShortcut = self.ToggleMenuItemsView.shortcutValue
            self.configureEnabledNoIconCheckbox()
        }
    }

    @IBAction private func launchAtLoginClicked(_ sender: NSButton) {
        LaunchAtLoginController.isEnabled = (sender.state == .on)
        sender.isChecked = LaunchAtLoginController.isEnabled
    }

    @IBAction private func hideStatusBarIconsAtLaunchClicked(_ sender: NSButton) {
        DozerIcons.shared.hideStatusBarIconsAtLaunch = HideStatusBarIconsAtLaunchCheckbox.isChecked
    }

    @IBAction private func hideStatusBarIconsAfterDelayClicked(_ sender: NSButton) {
        DozerIcons.shared.hideStatusBarIconsAfterDelay = HideStatusBarIconsAfterDelayCheckbox.isChecked
    }

    @IBAction private func hideStatusBarIconsSecondsUpdated(_ sender: NSPopUpButton) {
        Settings.hideAfterDelay = TimeInterval(HideStatusBarIconsSecondsPopUpButton.selectedTag())
        DozerIcons.shared.resetTimer()
    }

    @IBAction private func hideBothDozerIconsClicked(_ sender: NSButton) {
        DozerIcons.shared.hideBothDozerIcons = HideBothDozerIconsCheckbox.isChecked
    }

    @IBAction private func showIconAndMenuClicked(_ sender: NSButton) {
        DozerIcons.shared.enableIconAndMenu = ShowIconAndMenuCheckbox.isChecked
    }

    @IBAction private func fontSizeChanged(_ sender: NSPopUpButton) {
        DozerIcons.shared.iconFontSize = FontSizePopUpButton.selectedTag()
    }

    @IBAction private func buttonPaddingChanged(_ sender: NSPopUpButton) {
        DozerIcons.shared.buttonPadding = CGFloat(ButtonPaddingPopUpButton.selectedTag())
    }

    @IBAction private func enableRemoveDozerIconClicked(_ sender: NSButton) {
        DozerIcons.shared.enableRemoveDozerIcon = EnableRemoveDozerIconCheckbox.isChecked
    }

    /// disables the noIcon-checkbox if no shortcut is set and keeps track whether shortcut is set
    private func configureEnabledNoIconCheckbox() {
        if ToggleMenuItemsView.shortcutValue == nil {
            HideBothDozerIconsCheckbox.isEnabled = false
            Settings.isShortcutSet = false
        } else {
            HideBothDozerIconsCheckbox.isEnabled = true
        }
    }
}

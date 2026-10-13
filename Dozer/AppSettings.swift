/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa

extension Notification.Name {
    static let dozerShortcutSettingDidChange = Notification.Name("dozerShortcutSettingDidChange")
}

enum Settings {
    private static let defaults = UserDefaults.standard

    private enum Key {
        static let hideAtLaunchEnabled = "hideAtLaunchEnabled"
        static let hideAfterDelayEnabled = "hideAfterDelayEnabled"
        static let hideAfterDelay = "hideAfterDelay"
        static let noIconMode = "noIconMode"
        static let removeDozerIconEnabled = "removeStatusIconEnabled"
        static let showIconAndMenuEnabled = "showIconAndMenuEnabled"
        static let iconSize = "fontSize"
        static let buttonPadding = "buttonPadding"
        static let isShortcutSet = "isShortcutSet"
        static let shortcutKeyCode = "toggleMenuItemsKeyCode"
        static let shortcutModifiers = "toggleMenuItemsModifiers"
    }

    static var hideAtLaunchEnabled: Bool {
        get { defaults.bool(forKey: Key.hideAtLaunchEnabled) }
        set { defaults.set(newValue, forKey: Key.hideAtLaunchEnabled) }
    }

    static var hideAfterDelayEnabled: Bool {
        get { defaults.bool(forKey: Key.hideAfterDelayEnabled) }
        set { defaults.set(newValue, forKey: Key.hideAfterDelayEnabled) }
    }

    static var hideAfterDelay: TimeInterval {
        get {
            defaults.object(forKey: Key.hideAfterDelay) == nil
                ? 10
                : defaults.double(forKey: Key.hideAfterDelay)
        }
        set { defaults.set(newValue, forKey: Key.hideAfterDelay) }
    }

    static var noIconMode: Bool {
        get { defaults.bool(forKey: Key.noIconMode) }
        set { defaults.set(newValue, forKey: Key.noIconMode) }
    }

    static var removeDozerIconEnabled: Bool {
        get { defaults.bool(forKey: Key.removeDozerIconEnabled) }
        set { defaults.set(newValue, forKey: Key.removeDozerIconEnabled) }
    }

    static var showIconAndMenuEnabled: Bool {
        get { defaults.bool(forKey: Key.showIconAndMenuEnabled) }
        set { defaults.set(newValue, forKey: Key.showIconAndMenuEnabled) }
    }

    static var iconSize: Int {
        get {
            defaults.object(forKey: Key.iconSize) == nil
                ? 10
                : defaults.integer(forKey: Key.iconSize)
        }
        set { defaults.set(newValue, forKey: Key.iconSize) }
    }

    static var buttonPadding: CGFloat {
        get {
            defaults.object(forKey: Key.buttonPadding) == nil
                ? 25
                : CGFloat(defaults.double(forKey: Key.buttonPadding))
        }
        set { defaults.set(Double(newValue), forKey: Key.buttonPadding) }
    }

    static var isShortcutSet: Bool {
        get { shortcut != nil }
        set {
            if !newValue {
                shortcut = nil
            }
        }
    }

    static var shortcut: KeyboardShortcut? {
        get {
            guard defaults.object(forKey: Key.shortcutKeyCode) != nil,
                  defaults.object(forKey: Key.shortcutModifiers) != nil else {
                return nil
            }
            return KeyboardShortcut(
                keyCode: UInt32(defaults.integer(forKey: Key.shortcutKeyCode)),
                modifiers: UInt(defaults.integer(forKey: Key.shortcutModifiers))
            )
        }
        set {
            let wasSet = shortcut != nil
            if let newValue {
                defaults.set(Int(newValue.keyCode), forKey: Key.shortcutKeyCode)
                defaults.set(Int(newValue.modifiers), forKey: Key.shortcutModifiers)
            } else {
                defaults.removeObject(forKey: Key.shortcutKeyCode)
                defaults.removeObject(forKey: Key.shortcutModifiers)
            }
            if wasSet != (newValue != nil) {
                NotificationCenter.default.post(name: .dozerShortcutSettingDidChange, object: nil)
            }
        }
    }
}

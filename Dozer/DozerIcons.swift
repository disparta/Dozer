/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa

public final class DozerIcons {
    static var shared = DozerIcons()
    private var dozerIcons: [HelperstatusIcon] = []
    private var timerToCheckUserInteraction = Timer()
    private var timerToHideDozerIcons = Timer()
    private var previousApp = NSRunningApplication()
    private var shortcutObserver: NSObjectProtocol?

    private init() {
        dozerIcons.append(NormalStatusIcon())

        if !hideBothDozerIcons || !Settings.isShortcutSet {
            dozerIcons.append(NormalStatusIcon())
        }

        if enableRemoveDozerIcon {
            dozerIcons.append(RemoveStatusIcon())
        }

        if hideStatusBarIconsAfterDelay {
            startTimer()
        }

        shortcutObserver = NotificationCenter.default.addObserver(
            forName: .dozerShortcutSettingDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.triggerHideBothDozerIcons()
        }
    }

    deinit {
        if let shortcutObserver {
            NotificationCenter.default.removeObserver(shortcutObserver)
        }
    }

    private func startUserInteractionTimer() {
        guard Settings.hideAfterDelayEnabled else {
            stopUserInteractionTimer()
            return
        }
        timerToCheckUserInteraction = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if self.isUserInteractingWithStatusBar() {
                self.resetTimer()
            }
        }
    }

    private func stopUserInteractionTimer() {
        timerToCheckUserInteraction.invalidate()
    }

    // MARK: Observe changes to settings
    public var hideStatusBarIconsAtLaunch: Bool = Settings.hideAtLaunchEnabled {
        didSet {
            Settings.hideAtLaunchEnabled = hideStatusBarIconsAtLaunch
        }
    }

    public var hideStatusBarIconsAfterDelay: Bool = Settings.hideAfterDelayEnabled {
        didSet {
            Settings.hideAfterDelayEnabled = hideStatusBarIconsAfterDelay
            if hideStatusBarIconsAfterDelay {
                startTimer()
            } else {
                stopTimer()
            }
        }
    }

    public var hideBothDozerIcons: Bool = Settings.noIconMode {
        didSet {
            Settings.noIconMode = hideBothDozerIcons
            triggerHideBothDozerIcons()
        }
    }

    public func triggerHideBothDozerIcons() {
        let normalStatusIconsCount = dozerIcons.filter { $0.type == .normal}.count
        if hideBothDozerIcons && Settings.isShortcutSet {
            if normalStatusIconsCount == 2 {
                let rightDozerIconXPos = get(dozerIcon: .normalRight).xPositionOnScreen
                dozerIcons.removeAll { $0.xPositionOnScreen == rightDozerIconXPos }
            }
        } else if !hideBothDozerIcons && Settings.isShortcutSet || !Settings.isShortcutSet {
            if normalStatusIconsCount == 1 {
                show()
                dozerIcons.append(NormalStatusIcon())
            }
        }
        show()
    }

    public var enableRemoveDozerIcon: Bool = Settings.removeDozerIconEnabled {
        didSet {
            Settings.removeDozerIconEnabled = enableRemoveDozerIcon
            if enableRemoveDozerIcon {
                dozerIcons.append(RemoveStatusIcon())
            } else {
                dozerIcons.removeAll { $0.type == .remove }
            }
            showAll()
        }
    }

    public var enableIconAndMenu: Bool = Settings.showIconAndMenuEnabled {
        didSet {
            Settings.showIconAndMenuEnabled = enableIconAndMenu
            if self.enableIconAndMenu == false {
                _ = DozerIcons.toggleDockIcon(showIcon: false)
                appDelegate.preferencesWindowController.show(preferencePane: .general)
            }
        }
    }

    public var iconFontSize: Int = Settings.iconSize {
        didSet {
            Settings.iconSize = iconFontSize
            for icon in dozerIcons {
                icon.setSize()
            }
        }
    }

    public var buttonPadding: CGFloat = Settings.buttonPadding {
        didSet {
            Settings.buttonPadding = buttonPadding
            for icon in dozerIcons {
                icon.setSize()
            }
        }
    }

    // MARK: Public methods
    public func hide() {
        perform(action: .hide, statusIcon: .remove)
        perform(action: .hide, statusIcon: .normalLeft)
        if Settings.noIconMode && Settings.isShortcutSet {
            perform(action: .hide, statusIcon: .normalRight)
        }
        didHideStatusBarIcons()
        hideIconAndMenu()
    }

    public func hideAtLaunch() {
        if hideStatusBarIconsAtLaunch {
            if #available(macOS 11.0, *) {
                Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { _ in
                   self.hide()
                }
            } else {
                self.hide()
            }
        }
    }

    public func show() {
        resetTimer()
        perform(action: .hide, statusIcon: .remove)
        perform(action: .show, statusIcon: .normalLeft)
        if Settings.noIconMode {
            perform(action: .show, statusIcon: .normalRight)
        }
        didShowStatusBarIcons()
        showIconAndMenu()
    }

    public func toggle() {
        if get(dozerIcon: .normalLeft).isShown {
            hide()
        } else {
            show()
        }
    }

    public func toggleRemove() {
        if get(dozerIcon: .remove).isShown {
            perform(action: .hide, statusIcon: .remove)
        } else {
            perform(action: .show, statusIcon: .remove)
        }
    }

    public func showIconAndMenu() {
        if NSWorkspace.shared.frontmostApplication?.bundleIdentifier != AppInfo.bundleIdentifier {
            previousApp = NSWorkspace.shared.frontmostApplication!
        }
        if Settings.showIconAndMenuEnabled {
            _ = DozerIcons.toggleDockIcon(showIcon: true)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    public func hideIconAndMenu() {
        if Settings.showIconAndMenuEnabled {
            _ = DozerIcons.toggleDockIcon(showIcon: false)
            if NSWorkspace.shared.frontmostApplication?.bundleIdentifier == AppInfo.bundleIdentifier {
                previousApp.activate()
            }
        }
    }

    /// Force show all Dozer icons
    public func showAll() {
        perform(action: .show, statusIcon: .remove)
        perform(action: .show, statusIcon: .normalLeft)
        perform(action: .show, statusIcon: .normalRight)
        didShowStatusBarIcons()
    }

    public func handleOptionClick() {
        showIconAndMenu()
        if get(dozerIcon: .normalLeft).isShown {
            DozerIcons.shared.perform(
                action: .toggle,
                statusIcon: .remove
            )
        } else {
            DozerIcons.shared.perform(
                action: .show,
                statusIcon: .normalLeft
            )
            DozerIcons.shared.perform(
                action: .show,
                statusIcon: .remove
            )
        }
        stopUserInteractionTimer()
        startUserInteractionTimer()
        resetTimer()
    }

    // MARK: Show/hide lifecycle
    private func didShowStatusBarIcons() {
        //startTimer()
        startUserInteractionTimer()
    }

    private func didHideStatusBarIcons() {
        stopTimer()
        stopUserInteractionTimer()
    }

    private func willHideStatusBarIcons() {
        guard Settings.hideAfterDelayEnabled else {
            return
        }

        // don't hide on user interaction with menu bar
        guard !isUserInteractingWithStatusBar() else {
            resetTimer()
            return
        }

        DozerIcons.shared.hide()
    }

    // MARK: timerToHideDozerIcons methods
    private func startTimer() {
        guard Settings.hideAfterDelayEnabled else {
            stopTimer()
            return
        }
        timerToHideDozerIcons = Timer.scheduledTimer(withTimeInterval: Settings.hideAfterDelay, repeats: false) { (_: Timer) -> Void in
            self.willHideStatusBarIcons()
        }
    }

    private func stopTimer() {
        timerToHideDozerIcons.invalidate()
    }

    func resetTimer() {
        self.stopTimer()
        self.startTimer()
    }

    // MARK: Private methods
    /// Will fail silently if statusIcon does not exist
    private func perform(action: StatusIconAction, statusIcon: DozerIcon) {
        if statusIcon == .remove {
            guard Settings.removeDozerIconEnabled else {
                return
            }
        }
        let theStatusIcon: HelperstatusIcon = get(dozerIcon: statusIcon)
        switch action {
        case .show:
            theStatusIcon.show()
        case .hide:
            theStatusIcon.hide()
        case .toggle:
            theStatusIcon.toggle()
        }
    }

    /// Will crash if trying to get ´DozerIcon´ which does not exist in the menu bar
    private func get(dozerIcon: DozerIcon) -> HelperstatusIcon {
        var normalStatusIconsXPosition: [CGFloat] = []
        for statusIcon in dozerIcons where statusIcon.type == .normal {
            normalStatusIconsXPosition.append(statusIcon.xPositionOnScreen)
        }
        switch dozerIcon {
        case .remove:
            guard let removeStatusIcon = dozerIcons.first(where: { $0.type == .remove }) else {
                fatalError("Failed getting remove status icon")
            }
            return removeStatusIcon
        case .normalLeft:
            guard let leftStatusIcon = dozerIcons.first(where: { $0.xPositionOnScreen == normalStatusIconsXPosition.min() }) else {
                fatalError("Failed getting status icon on the left")
            }
            return leftStatusIcon
        case .normalRight:
            guard let rightStatusIcon = dozerIcons.first(where: { $0.xPositionOnScreen == normalStatusIconsXPosition.max() }) else {
                fatalError("Failed getting status icon on the right")
            }
            return rightStatusIcon
        }
    }

    /// hide and show dock icon and thus its menu bar: to free up space to show more menu bar icons
    public class func toggleDockIcon(showIcon state: Bool) -> Bool {
        if state {
            return NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
        } else {
            return NSApp.setActivationPolicy(NSApplication.ActivationPolicy.accessory)
        }
    }

    /// Determines if the user is interacting with the menu bar based on level, owner and y-coordinate
    ///
    /// - Returns: Returns whether the user is interacting with the menu bar or not
    private func isUserInteractingWithStatusBar() -> Bool {
        let windowListType = CGWindowListOption.optionOnScreenOnly
        guard let windowInfoList = CGWindowListCopyWindowInfo(windowListType, kCGNullWindowID) as NSArray? as? [[String: AnyObject]] else {
            return false
        }
        var statusBarAppsWindowInfo: [Window] = []

        for windowInfo in windowInfoList {
            guard let window = Window(windowInfo),
                // If the preferences window are close to the menu bar it won't auto hide
                window.owner != "Dozer" else {
                    continue
            }

            if window.isStatusIcon {
                statusBarAppsWindowInfo.append(window)
            }
        }

        for windowInfo in windowInfoList {
            guard let window = Window(windowInfo) else { continue }
            guard window.isStatusIcon == false else { continue }

            for statusBarApp in statusBarAppsWindowInfo {
                guard statusBarApp.owner == window.owner else { continue }
                guard (statusBarApp.y + 22...statusBarApp.y + 30).contains(window.y) else { continue }

                return true
            }
        }

        return false
    }

    /// Wrapper class for CGWindowList
    private class Window {
        var x: Int = 0
        var y: Int = 0
        var width: Int = 0
        var height: Int = 0

        var level: Int
        var owner: String

        init?(_ windowInfo: [String: AnyObject]) {
            guard let level = windowInfo[kCGWindowLayer as String] as? Int else {
                return nil
            }
            guard let owner = windowInfo[kCGWindowOwnerName as String] as? String else {
                return nil
            }

            self.level = level
            self.owner = owner

            guard let boundsValue = windowInfo[kCGWindowBounds as String] else {
                return nil
            }
            let bounds = boundsValue as! CFDictionary
            guard let rect = CGRect(dictionaryRepresentation: bounds) else {
                return nil
            }
            x = Int(rect.origin.x)
            y = Int(rect.origin.y)
            width = Int(rect.width)
            height = Int(rect.height)
        }

        var isStatusIcon: Bool {
            let statusWindowLevel = Int(CGWindowLevelForKey(.statusWindow))
            return level == statusWindowLevel && height > 0 && height <= 40
        }
    }
}

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa

struct PreferencePaneIdentifier: RawRepresentable, Equatable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

protocol PreferencePane where Self: NSViewController {
    var preferencePaneIdentifier: PreferencePaneIdentifier { get }
    var preferencePaneTitle: String { get }
    var toolbarItemIcon: NSImage { get }
}

final class PreferencesWindowController: NSWindowController {
    private let panes: [NSViewController & PreferencePane]
    private let tabs = NSTabViewController()

    init(preferencePanes: [NSViewController & PreferencePane]) {
        panes = preferencePanes

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Dozer Settings"
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)

        tabs.tabStyle = .toolbar
        for pane in panes {
            let item = NSTabViewItem(viewController: pane)
            item.label = pane.preferencePaneTitle
            item.image = pane.toolbarItemIcon
            tabs.addTabViewItem(item)
        }
        window.contentViewController = tabs
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(preferencePane identifier: PreferencePaneIdentifier) {
        if let index = panes.firstIndex(where: { $0.preferencePaneIdentifier == identifier }) {
            tabs.selectedTabViewItemIndex = index
        }
        showWindow(nil)
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

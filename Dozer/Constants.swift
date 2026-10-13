/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa

extension PreferencePaneIdentifier {
    static let dozer = Self("dozer")
    static let general = Self("general")
}

struct AppInfo {
    static let bundleIdentifier: String = Bundle.main.bundleIdentifier!
    static var releaseVersionNumber: String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    static var buildVersionNumber: String? {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}

enum StatusIconAction {
    case show
    case hide
    case toggle
}

enum StatusIconType {
    case normal
    case remove
}

enum DozerIcon {
    case remove
    case normalLeft
    case normalRight
}

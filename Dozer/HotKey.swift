/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

import Cocoa
import Carbon

struct KeyboardShortcut: Equatable {
    let keyCode: UInt32
    let modifiers: UInt

    var displayName: String {
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        var value = ""
        if flags.contains(.control) { value += "⌃" }
        if flags.contains(.option) { value += "⌥" }
        if flags.contains(.shift) { value += "⇧" }
        if flags.contains(.command) { value += "⌘" }
        value += Self.keyName(for: keyCode)
        return value
    }

    private static func keyName(for keyCode: UInt32) -> String {
        let names: [UInt32: String] = [
            36: "↩", 48: "⇥", 49: "Space", 51: "⌫", 53: "⎋",
            115: "↖", 116: "⇞", 117: "⌦", 119: "↘", 121: "⇟",
            123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        if let name = names[keyCode] {
            return name
        }

        let source = TISCopyCurrentKeyboardLayoutInputSource().takeRetainedValue()
        guard let dataPointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            return "Key \(keyCode)"
        }
        let data = Unmanaged<CFData>.fromOpaque(dataPointer).takeUnretainedValue()
        guard let bytes = CFDataGetBytePtr(data) else {
            return "Key \(keyCode)"
        }
        let layout = UnsafePointer<UCKeyboardLayout>(OpaquePointer(bytes))
        var deadKeyState: UInt32 = 0
        var length = 0
        var characters = [UniChar](repeating: 0, count: 4)
        let result = UCKeyTranslate(
            layout,
            UInt16(keyCode),
            UInt16(kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            OptionBits(kUCKeyTranslateNoDeadKeysBit),
            &deadKeyState,
            characters.count,
            &length,
            &characters
        )
        guard result == noErr, length > 0 else {
            return "Key \(keyCode)"
        }
        return String(utf16CodeUnits: characters, count: length).uppercased()
    }
}

final class HotKeyManager {
    static let shared = HotKeyManager()

    var handler: (() -> Void)?

    private var hotKey: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?
    private let hotKeyID = EventHotKeyID(signature: OSType(0x445A4552), id: 1) // DZER

    private init() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData -> OSStatus in
                guard let event, let userData else {
                    return OSStatus(eventNotHandledErr)
                }
                var receivedID = EventHotKeyID()
                let status = GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &receivedID
                )
                guard status == noErr, receivedID.id == 1 else {
                    return OSStatus(eventNotHandledErr)
                }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                manager.handler?()
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    deinit {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }
        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }

    func register(_ shortcut: KeyboardShortcut?) {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
            self.hotKey = nil
        }
        guard let shortcut else {
            return
        }

        let flags = NSEvent.ModifierFlags(rawValue: shortcut.modifiers)
        var carbonModifiers: UInt32 = 0
        if flags.contains(.command) { carbonModifiers |= UInt32(cmdKey) }
        if flags.contains(.option) { carbonModifiers |= UInt32(optionKey) }
        if flags.contains(.control) { carbonModifiers |= UInt32(controlKey) }
        if flags.contains(.shift) { carbonModifiers |= UInt32(shiftKey) }

        RegisterEventHotKey(
            shortcut.keyCode,
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKey
        )
    }
}

final class ShortcutRecorderView: NSView {
    var shortcutValueChange: ((KeyboardShortcut?) -> Void)?
    var shortcutValue: KeyboardShortcut? { Settings.shortcut }

    private let button = NSButton()
    private var eventMonitor: Any?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    deinit {
        stopRecording()
    }

    private func configure() {
        button.bezelStyle = .rounded
        button.target = self
        button.action = #selector(beginRecording)
        button.autoresizingMask = [.width, .height]
        button.frame = bounds
        addSubview(button)
        updateTitle()
    }

    @objc private func beginRecording() {
        stopRecording()
        button.title = "Type shortcut…"
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.capture(event)
            return nil
        }
    }

    private func capture(_ event: NSEvent) {
        if event.keyCode == 53 {
            Settings.shortcut = nil
        } else {
            let allowed: NSEvent.ModifierFlags = [.command, .option, .control, .shift]
            let modifiers = event.modifierFlags.intersection(allowed)
            guard !modifiers.isEmpty else {
                NSSound.beep()
                return
            }
            Settings.shortcut = KeyboardShortcut(
                keyCode: UInt32(event.keyCode),
                modifiers: modifiers.rawValue
            )
        }
        HotKeyManager.shared.register(Settings.shortcut)
        stopRecording()
        updateTitle()
        shortcutValueChange?(Settings.shortcut)
    }

    private func updateTitle() {
        button.title = Settings.shortcut?.displayName ?? "Record Shortcut"
    }

    private func stopRecording() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
    }
}

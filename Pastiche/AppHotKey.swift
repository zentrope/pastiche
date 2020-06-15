//
//  AppHotKey.swift
//  Pastiche
//
//  Created by Keith Irwin on 6/14/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Carbon
import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppHotKey")

// https://stackoverflow.com/a/58225397
// https://github.com/soffes/HotKey/blob/master/Sources/HotKey/HotKeysController.swift?ts=4

final class AppHotKey {

    static let RETURN = Int(kVK_Return)
    static let ESCAPE = Int(kVK_Escape)
    static let DELETE = Int(kVK_Delete)
    static let FORWARD_DELETE = Int(kVK_ForwardDelete)
    
    static let signature = "PSTC".fourCharCodeValue

    static func listenForHotKey() {
        listenForHotKeyCarbon()
    }

    static func listenForHotKeyCocoa() {
        let mask: NSEvent.ModifierFlags = [.command, .shift]
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) {
            if $0.modifierFlags.intersection(mask) == mask && $0.keyCode == kVK_ANSI_V {
                NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            }
        }
    }

    static func listenForHotKeyCarbon() {

        let keyCode = UInt32(kVK_ANSI_V)
        let modifierFlags = UInt32(cmdKey | shiftKey)

        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(AppHotKey.signature)
        hotKeyID.id = keyCode

        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)

        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKey = EventHotKeyID()
            os_log("%{public}s", log: logger, "HotKey handler invoked.")
            let error = GetEventParameter(theEvent,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hotKey)
            if error != noErr {
                os_log("%{public}s", log: logger, type: .error, "HotKey handler error: \(error).")
                return error
            }

            if (hotKey.signature != AppHotKey.signature) {
                os_log("%{public}s", log: logger, type: .debug, "HotKey signature mismatch.")
                return OSStatus(eventNotHandledErr)
            }

            NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            return noErr
        }, 1, &eventType, nil, nil)

        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        assert(status == noErr)
    }
}

extension String {
    var fourCharCodeValue: FourCharCode {
        var result: FourCharCode = 0
        for char in self.utf16 {
            result = (result << 8) + FourCharCode(char)
        }
        return result
    }
}

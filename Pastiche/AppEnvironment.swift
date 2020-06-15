//
//  AppEnvironment.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/31/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppEnvironment")

class AppEnvironment {

    static var shared = AppEnvironment()

    var isTrusted = false {
        didSet {
            os_log("%{public}s", log: logger, "app is \(isTrusted ? "trusted" : "not trusted")")
        }
    }

    private var isStarted = false

    private init() {}

    func start() {
        guard !isStarted else { return }

        refreshPasteboard()
        requestAccessibilityPermissions()
        isStarted = true
    }

    func send(paste: Paste) {
        guard let value = paste.value else { return }

        NSApp.hide(self)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        self.forgePasteEvent()
    }

    private func addPasteItem(_ value: String) {
        AppData.shared.upsert(paste: value) { error in
            os_log("%{public}s", log: logger, type: .error, "\(error)")
        }
    }

    // MARK: - Implementation Details

    private func forgePasteEvent () {
        // For some reason, doing this delays just enough for the other app to be ready to
        // receive events.
        DispatchQueue.main.async {
            let event1 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: true); // cmd-v down
            event1?.flags = CGEventFlags.maskCommand;
            event1?.post(tap: CGEventTapLocation.cghidEventTap);
            let event2 = CGEvent(keyboardEventSource: nil, virtualKey: 0x09, keyDown: false) // cmd-v up
            event2?.post(tap: CGEventTapLocation.cghidEventTap)
        }
    }

    private func updatePasteboard(_ pasteboardCount: Int) -> Int {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount == pasteboardCount {
            return pasteboardCount
        }

        let myTypes: [NSPasteboard.PasteboardType] = [.string, .URL, .fileURL]
        for item in pasteboard.pasteboardItems ?? [] {
            if let itemType = item.availableType(from: myTypes),
                let paste = item.string(forType: itemType) {
                addPasteItem(paste)
            }
        }
        return pasteboard.changeCount
    }

    private func requestAccessibilityPermissions() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options = [checkOptPrompt : true]

        isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }

    func refreshPasteboard(_ pasteboardCount: Int = 0) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let newCount = self.updatePasteboard(pasteboardCount)
            self.refreshPasteboard(newCount)
        }
    }
}

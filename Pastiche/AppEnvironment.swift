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

    var mostRecentRunningApplication: NSRunningApplication?

    var isTrusted = false {
        didSet {
            print("app is \(isTrusted ? "trusted" : "not trusted")")
        }
    }

    private var isStarted = false

    private init() {}

    func start() {
        guard !isStarted else { return }

        refreshPasteboard()
        listenForAppActivations()
        requestAccessibilityPermissions()
        isStarted = true
    }

    func send(paste: Paste) {
        guard let app = mostRecentRunningApplication,
            let value = paste.value else { return }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        if app.activate(options: [.activateIgnoringOtherApps]) {
            self.forgePasteEvent()
        }
    }

    func returnToCaller() {
        mostRecentRunningApplication?.activate(options: [.activateIgnoringOtherApps])
        NSApp.hide(self)
    }

    private func addPasteItem(_ value: String) {
        AppData.shared.upsert(paste: value) { error in
            print("ERROR: \(error)")
        }
    }

    // MARK: - Implementation Details

    private func forgePasteEvent () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

    private func updateRecentActiveApp(_ info: [AnyHashable:Any]?) {
        if let app = info?["NSWorkspaceApplicationKey"] as? NSRunningApplication,
            let local = app.localizedName, !(Bundle.main.bundleIdentifier ?? "").hasSuffix(local) {

            mostRecentRunningApplication = app
            print("activated: '\(local)'")
            return
        }
    }

    private func requestAccessibilityPermissions() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString
        let options = [checkOptPrompt : true]

        isTrusted = AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }

    private func listenForAppActivations() {
        let center = NSWorkspace.shared.notificationCenter
        let notification = NSWorkspace.didActivateApplicationNotification
        center.addObserver(forName: notification, object: nil, queue: .main) { [weak self] msg in
            guard let self = self else { return }
            self.updateRecentActiveApp(msg.userInfo)
        }
    }

    func refreshPasteboard(_ pasteboardCount: Int = 0) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            guard let self = self else { return }
            let newCount = self.updatePasteboard(pasteboardCount)
            self.refreshPasteboard(newCount)
        }
    }
}

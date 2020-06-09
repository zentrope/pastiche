//
//  AppEnvironment.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/31/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

import os.log

//extension Notification.Name {
//    static let newPasteDidArrive = Notification.Name("newPasteDidArrive")
//}

class AppEnvironment {

    static var shared = AppEnvironment()

//    struct PasteItem: Equatable {
//        var timestamp = Date()
//        var item: String
//        var name: String
//
//        static func == (lhs: PasteItem, rhs: PasteItem) -> Bool {
//            return lhs.item == rhs.item
//        }
//    }

    var mostRecentRunningApplication: NSRunningApplication?

    var isTrusted = false {
        didSet {
            print("app is \(isTrusted ? "trusted" : "not trusted")")
        }
    }

    //var pasteItems = [PasteItem]()
    private var isStarted = false

    private init() {}

    func start() {
        guard !isStarted else { return }

        refreshPasteboard()
        listenForAppActivations()
        requestAccessibilityPermissions()
        isStarted = true
    }

    func returnToCaller() {
        mostRecentRunningApplication?.activate(options: [.activateIgnoringOtherApps])
        NSApp.hide(self)
    }

    private func addPasteItem(_ value: String) {
        AppData.shared.upsert(paste: value) { error in
            print("ERROR: \(error)")
        }
        /*
        let name = value.flattened().trimmed().sized(100)
        let paste = PasteItem(item: value, name: name)

        // Even if the paste is a duplicate, it should always
        // appear as the first element. So, re-copying text
        // will always move it to the top of the list with a
        // new timestamp.

        if pasteItems.contains(paste) {
            pasteItems.removeAll { $0 == paste }
        }
        pasteItems.insert(paste, at: 0)
        NotificationCenter.default.post(name: .newPasteDidArrive, object: self)
        */
    }

    // MARK: - Implementation Details

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

//extension String {
//
//    func trimmed() -> String {
//        trimmingCharacters(in: .whitespacesAndNewlines)
//    }
//
//    func flattened() -> String {
//        if let regex = try? NSRegularExpression(pattern: "\\s+", options: []) {
//            return regex.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: " ")
//        }
//        return self
//    }
//
//    func sized(_ n: Int) -> String {
//        // FIXME: Reconsider ellipses once we've moved to a UI
//        count <= n ? self : String(self[startIndex...index(startIndex, offsetBy: n)])
//    }
//}

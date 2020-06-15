//
//  AppDelegate.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/15/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Carbon
import Cocoa
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var windowController = WindowController()
    private var appEnvironment = AppEnvironment.shared

    var pasteboardCount = 0

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        os_log("%{public}s", log: logger, "Application started.")
        windowController.showWindow(self)
        appEnvironment.start()
        AppHotKey.listenForHotKey()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        os_log("%{public}s", log: logger, "Shutting down application.")
        AppData.shared.save { (error) in
            os_log("%{public}s", log: logger, type: .error, "\(error)")
        }
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        windowController.showWindow(self)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        windowController.showWindow(self)
        return true
    }

}

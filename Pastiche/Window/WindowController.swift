//
//  WindowController.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/31/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    private var controller: ViewController?

    convenience init() {
        self.init(windowNibName: "")
        controller = ViewController()
    }

    override func loadWindow() {
        let pos = NSMakeRect(200, 200, 600, 600)
        let mask: NSWindow.StyleMask = [.closable, .resizable, .titled, .miniaturizable]
        window = NSWindow(contentRect: pos, styleMask: mask, backing: .buffered, defer: true)
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        guard let window = window else { return }

        window.contentViewController = controller
        window.tabbingMode = .disallowed
        window.titleVisibility = .hidden
        window.setFrameAutosaveName("Pastiche.MainWindow")
    }

}

extension WindowController: NSWindowDelegate {

    func windowWillClose(_ notification: Notification) {
        print("main window closed")
    }
}

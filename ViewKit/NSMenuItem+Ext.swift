//
//  NSMenuItem+Ext.swift
//  Hours
//
//  Created by Keith Irwin on 3/22/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSMenuItem {

    private static var boldFont = NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .semibold)

    func emphasize() {
        self.attributedTitle = NSMutableAttributedString()
            .append(self.title, [.font: NSMenuItem.boldFont])
    }

    func diminish() {
        self.attributedTitle = NSMutableAttributedString()
            .append(self.title, [.foregroundColor: NSColor.tertiaryLabelColor])
    }
}

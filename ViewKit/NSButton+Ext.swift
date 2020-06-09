//
//  NSButton+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSButton {

    convenience init(small title: String = "", target: Any? = nil, action: Selector? = nil) {
        self.init(title: title, target: target, action: action)
        controlSize = .small
        font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
    }

    convenience init(title: String) {
        self.init(title: title, target: nil, action: nil)
        self.title = title
    }

    convenience init(image: NSImage) {
        self.init(image: image, target: nil, action: nil)
    }

    convenience init(glyph: NSImage) {
        self.init(image: glyph.scaled(toHeight: 14).asTemplate(), target: nil, action: nil)
        isBordered = false
        setButtonType(.momentaryChange)
        imageScaling = .scaleProportionallyDown
        width(22)
    }
}

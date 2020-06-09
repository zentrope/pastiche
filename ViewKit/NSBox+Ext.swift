//
//  NSBox+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSBox {
    static func separator() -> NSBox {
        let box = NSBox()
        box.boxType = .separator
        return box
    }

    static func separator(height: CGFloat = 0, width: CGFloat = 0) -> NSBox {
        let box = NSBox()
        box.boxType = .separator

        if height > 0 {
            box.height(height)
        }

        if width > 0 {
            box.width(width)
        }
        return box
    }

}

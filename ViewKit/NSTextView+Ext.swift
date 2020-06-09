//
//  NSTextView+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSTextView {

    var isScrolledToBottom: Bool {
        get {
            guard let documentView = enclosingScrollView?.documentView else { return false }
            guard let clipView = enclosingScrollView?.contentView else { return false }
            let clipHeight = clipView.bounds.origin.y + clipView.bounds.height
            let docHeight = documentView.bounds.height
            return clipHeight == docHeight
        }
    }
}


//
//  AutoResizingTextField.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/15/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

final class AutoResizingTextField: NSTextField {

    init() {
        super.init(frame: .zero)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultHigh, for: .vertical)
        cell?.sendsActionOnEndEditing = true
        cell?.wraps = true
        focusRingType = .none
        isEditable = true
        usesSingleLineMode = false
        lineBreakMode = .byWordWrapping
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: NSSize {
        if cell!.wraps {
            let fictionalBounds = NSRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: 10000)
            return cell!.cellSize(forBounds: fictionalBounds)
        } else {
            return super.intrinsicContentSize
        }
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)

        if cell!.wraps {
            validateEditing()
            invalidateIntrinsicContentSize()
        }
    }

    override func updateLayer() {
        layer?.backgroundColor = NSColor.textBackgroundColor.cgColor
        layer?.cornerRadius = 4
        layer?.borderWidth = 0.5
        layer?.borderColor = NSColor.gridColor.cgColor
    }
}


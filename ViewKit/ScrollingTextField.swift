//
//  ScrollingTextField.swift
//  Hours
//
//  Created by Keith Irwin on 3/20/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

public final class ScrollingTextField: NSView {
    private var textView = NSTextView()
    private var scrollView = NSScrollView()

    public var stringValue: String {
        get {
            textView.string
        }
        set (newValue) {
            textView.string = newValue
        }
    }

    public var font: NSFont? {
        get {
            textView.font
        }
        set (newValue) {
            textView.font = newValue
        }
    }

    public var isEditable: Bool {
        get { textView.isEditable }
        set (newValue) { textView.isEditable = newValue } }

    public var isSelectable: Bool {
        get { textView.isSelectable }
        set (newValue) { textView.isSelectable = newValue } }

    var textDidChange: ((ScrollingTextField) -> Void)?

    convenience init() {
        self.init(frame: .zero)
        textView.isEditable = true
        textView.isRichText = false
        textView.textContainerInset = NSMakeSize(0, 2)
        textView.autoresizingMask = [.width, .height]
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.allowsUndo = false
        textView.usesFindBar = false
        textView.isIncrementalSearchingEnabled = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false

        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        fill(subview: scrollView)
        textView.delegate = self
        scrollView.focusRingType = .exterior
    }
}

extension ScrollingTextField: NSTextViewDelegate {

    public func textDidChange(_ notification: Notification) {
        textDidChange?(self)
    }

    public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {

        case #selector(NSStandardKeyBindingResponding.insertBacktab(_:)):
            window?.selectPreviousKeyView(self)
            return true

        case #selector(NSStandardKeyBindingResponding.insertTab(_:)):
            window?.selectNextKeyView(self)
            return true

        default:
            return false
        }
    }
}

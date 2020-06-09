//
//  NSStackView+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSStackView {

    @discardableResult
    func leading(_ view: NSView, spacesAfter: CGFloat = 0) -> Self {
        addView(view, in: .leading)
        if spacesAfter != 0 {
            setCustomSpacing(spacesAfter, after: view)
        }
        return self
    }

    @discardableResult
    func center(_ view: NSView) -> Self {
        addView(view, in: .center)
        return self
    }

    @discardableResult
    func trailing(_ view: NSView) -> Self {
        addView(view, in: .trailing)
        return self
    }

    @discardableResult
    func insets(vertical v: CGFloat, horizontal h: CGFloat) -> Self {
        edgeInsets = NSEdgeInsetsMake(v, h, v, h)
        return self
    }

    @discardableResult
    func insets(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) -> Self {
        edgeInsets = NSEdgeInsetsMake(top, left, bottom, right)
        return self
    }

    @discardableResult
    func spacing(_ value: CGFloat) -> Self {
        spacing = value
        return self
    }

    @discardableResult
    func spaces(_ value: CGFloat) -> Self {
        if let view = views.last {
            setCustomSpacing(value, after: view)
        }
        return self
    }

    @discardableResult
    func hugLowHorizontal() -> Self {
        setHuggingPriority(.defaultLow, for: .horizontal)
        return self
    }

    @discardableResult
    func hugLowVertical() -> Self {
        setHuggingPriority(.defaultLow, for: .vertical)
        return self
    }

    @discardableResult
    func hugHighVertical() -> Self {
        setHuggingPriority(.defaultHigh, for: .vertical)
        return self
    }

    @discardableResult
    func hugHighHorizontal() -> Self {
        setHuggingPriority(.defaultHigh, for: .horizontal)
        return self
    }

    func embedInScrollView() -> NSScrollView {
        translatesAutoresizingMaskIntoConstraints = false

        let scroller = NSScrollView()
        scroller.documentView = self
        scroller.hasVerticalScroller = true
        scroller.contentView.setValue(true, forKey: "flipped")
        scroller.drawsBackground = false

        return scroller
    }

    @discardableResult
    func removeAll() -> Self {
        subviews.forEach { $0.removeFromSuperview() }
        return self
    }
}


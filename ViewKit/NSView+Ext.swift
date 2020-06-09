//
//  NSView+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/09/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

fileprivate class Style {

    // If views get deallocated, style objects should also get deallocated.
    static let cache = NSMapTable<NSObject, Style>(keyOptions: .weakMemory, valueOptions: .strongMemory)

    var backgroundColor: NSColor?
    var cornerRadius: CGFloat = 0
    var borderWidth: CGFloat = 0
    var borderColor: NSColor?

    static func get(_ key: NSObject) -> Style {
        if let style = cache.object(forKey: key) {
            return style
        }
        let newValue = Style()
        cache.setObject(newValue, forKey: key)
        return newValue
    }

    static func contains(_ key: NSObject) -> Bool {
        cache.object(forKey: key) != nil
    }
}

extension NSView {

    private var styleBackgroundColor: NSColor? {
        get { Style.get(self).backgroundColor }
        set { Style.get(self).backgroundColor = newValue }}

    private var styleCornerRadius: CGFloat {
        get { Style.get(self).cornerRadius }
        set { Style.get(self).cornerRadius = newValue }}

    private var styleBorderColor: NSColor? {
        get { Style.get(self).borderColor }
        set { Style.get(self).borderColor = newValue }}

    private var styleBorderWidth: CGFloat {
        get { Style.get(self).borderWidth }
        set { Style.get(self).borderWidth = newValue }}

    /// In order for the style system to work, NSView derivatives must override updateLayer() and call this function.
    func applyLayerStyles() {
        // Don't do anything if nothing has been set for this object. If we proceed, the style cache will get an empty, unused style value.
        guard Style.contains(self) else { return }
        wantsLayer = true
        guard let layer = layer else { return }
        layer.masksToBounds = true
        layer.backgroundColor = styleBackgroundColor?.cgColor
        layer.cornerRadius = styleCornerRadius
        layer.borderWidth  = styleBorderWidth
        layer.borderColor = styleBorderColor?.cgColor
    }

    @discardableResult
    func background(_ color: NSColor?) -> Self {
        styleBackgroundColor = color
        return self
    }

    @discardableResult
    func border(_ color: NSColor?, width: CGFloat? = 1) -> Self {
        styleBorderColor = color
        styleBorderWidth = width ?? 0
        return self
    }

    @discardableResult
    func corner(_ radius: CGFloat?) -> Self {
        styleCornerRadius = radius ?? 0
        return self
    }

    @discardableResult
    func style(background: NSColor? = nil, borderColor: NSColor? = nil, borderWidth: CGFloat? = nil, cornerRadius: CGFloat? = nil) -> Self {
        return self.background(background)
            .border(borderColor, width: borderWidth)
            .corner(cornerRadius)
    }

    @discardableResult
    func style(material: NSVisualEffectView.Material, blendingMode: NSVisualEffectView.BlendingMode) -> Self {
        let fx = NSVisualEffectView()
        fx.material = material
        fx.blendingMode = blendingMode
        fill(subview: fx)
        return self
    }
}

extension NSView {

    @discardableResult
    public func fill(subview: NSView, margin: CGFloat = 0) -> Self {
        return fill(subview: subview, top: margin, leading: margin, bottom: -margin, trailing: -margin)
    }

    @discardableResult
    public func fill(subview: NSView, top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
        return self
    }

    /// Center the subview according to the container's X and Y anchors.
    @discardableResult
    public func center(subview: NSView) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    /// Orient subview horizontally, centered on Y, with optional leading and trailing
    @discardableResult
    public func horizontal(subview: NSView, leading: CGFloat = 0, trailing: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    @discardableResult
    func centerLeading(subview: NSView, leading: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    @discardableResult
    func centerTrailing(subview: NSView, trailing: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    @discardableResult
    func top(subview: NSView, withMargins margin: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
        ])
        return self
    }

    @discardableResult
    func bottom(subview: NSView, withMargins margin: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
        ])
        return self
    }

    @discardableResult
    func between(top: NSView, subview: NSView, bottom: NSView) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.topAnchor.constraint(equalTo: top.bottomAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
        ])
        return self
    }

    @discardableResult
    func below(top: NSView, subview: NSView, scrollViewAdjust: Bool = false) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: top.bottomAnchor, constant: scrollViewAdjust ? -1 : 0),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        return self
    }

    @discardableResult
    func above(bottom: NSView, subview: NSView) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
        ])
        return self
    }

    @discardableResult
    public func height(_ height: CGFloat) -> Self {
        assert(height > 0)
        heightAnchor.constraint(equalToConstant: height).isActive = true
        return self
    }

    @discardableResult
    public func width(_ width: CGFloat) -> Self {
        assert(width > 0)
        widthAnchor.constraint(equalToConstant: width).isActive = true
        return self
    }

    @discardableResult
    public func maxWidth(_ width: CGFloat) -> Self {
        assert(width > 0)
        widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
        return self
    }

    @discardableResult
    public func minHeight(_ height: CGFloat) -> Self {
        assert(height > 0)
        heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        return self
    }

    @discardableResult
    public func minWidth(_ width: CGFloat) -> Self {
        assert(width > 0)
        widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        return self
    }

    @discardableResult
    public func min(width: CGFloat, height: CGFloat) -> Self {
        minWidth(width)
        minHeight(height)
        return self
    }

    @discardableResult
    public func borderize(_ color: NSColor = NSColor.systemRed, width: CGFloat = 0.5) -> Self {
        self.wantsLayer = true
        layer?.borderWidth = width
        layer?.borderColor = color.cgColor
        return self
    }

}

//
//  NSLayerView.swift
//  Hours
//
//  Created by Keith Irwin on 4/7/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

open class NSLayerView: NSView {

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    public override var wantsUpdateLayer: Bool { true }

    public override func updateLayer() {
        super.applyLayerStyles()
    }
}

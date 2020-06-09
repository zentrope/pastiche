//
//  GridClibTableView.swift
//  Vanilla Data
//
//  Created by Keith Irwin on 12/3/18.
//  Copyright © 2018 Zentrope. All rights reserved.
//

import Cocoa

public class GridClipTableView: NSTableView {
    // This prevents tables from showing gridlines for empty
    // underflow cells.
    public override func drawGrid(inClipRect clipRect: NSRect) { }

    public override var wantsUpdateLayer: Bool { true }

    public override func updateLayer() {
        self.applyLayerStyles()
    }
}

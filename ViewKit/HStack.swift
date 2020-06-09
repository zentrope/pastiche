//
//  HStack.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

class HStack: NSStackView {

    init() {
        super.init(frame: .zero)
        orientation = .horizontal
        distribution = .gravityAreas
        alignment = .centerY
        setHuggingPriority(.defaultHigh, for: .vertical)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateLayer() {
        super.applyLayerStyles()
    }
}


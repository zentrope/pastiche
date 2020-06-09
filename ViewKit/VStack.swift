//
//  VStack.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

class VStack: NSStackView {

    init() {
        super.init(frame: .zero)
        orientation = .vertical
        distribution = .gravityAreas
        alignment = .leading
        setHuggingPriority(.defaultHigh, for: .horizontal)
        spacing = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateLayer() {
        super.applyLayerStyles()
    }
}

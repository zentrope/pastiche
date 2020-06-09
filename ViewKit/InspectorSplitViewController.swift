//
//  InspectorSplitViewController.swift
//  Hours
//
//  Created by Keith Irwin on 3/22/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

final class InspectorSplitViewController: NSSplitViewController {

    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        super.splitView(splitView, canCollapseSubview: subview)
        if splitView.arrangedSubviews.count <= 1 {
            return false
        }
        return splitView.arrangedSubviews.last == subview
    }

    @objc func toggleInspector(_ sender: Any?) {
        guard splitViewItems.count >= 1 else { return }
        let item = splitViewItems[1]
        NSAnimationContext.runAnimationGroup() { ctx in
            ctx.duration = 0.5
            ctx.allowsImplicitAnimation = true
            item.isCollapsed.toggle()
        }
    }
}

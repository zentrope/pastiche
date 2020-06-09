//
//  NSImage+Ext.swift
//  Pastiche
//
//  Created by Keith Irwin on 5/31/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSImage {

    func asTemplate() -> Self {
        isTemplate = true
        return self
    }

    func unTemplate() -> Self {
        isTemplate = false
        return self
    }

    func scaled(toHeight height: CGFloat) -> NSImage {
        let width = height / self.size.height * self.size.width
        return resized(to: NSMakeSize(width, height))
    }

    func resized(to destSize: NSSize) -> NSImage {
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }

    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}

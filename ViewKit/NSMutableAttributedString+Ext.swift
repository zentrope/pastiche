//
//  NSMutableAttributedString+Ext.swift
//  Casual IRC
//
//  Created by Keith Irwin on 2/9/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Cocoa

extension NSMutableAttributedString {

    static let detector: NSDataDetector? = {
        let types: NSTextCheckingResult.CheckingType = [.link]
        return try? NSDataDetector(types: types.rawValue)
    }()

    func linkify() -> Self {
        guard let detector = NSMutableAttributedString.detector else { return self }
        let range = NSRange(self.string.startIndex..<self.string.endIndex, in: self.string)
        detector.enumerateMatches(in: self.string, options: [], range: range) { (match, _, _) in
            guard let match = match else { return }
            addAttribute(.link, value: match.url!, range: match.range)
        }
        return self
    }

    func newline() -> Self {
        append(NSAttributedString(string: "\n"))
        return self
    }

    func append(string: String, attributes: [NSAttributedString.Key:Any] = [:]) -> Self {
        append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func append(_ string: String, _ attributes: [NSAttributedString.Key:Any] = [:]) -> Self {
        append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func attributes(_ attributes: [NSAttributedString.Key:Any]) -> Self {
        addAttributes(attributes, range: NSMakeRange(0, length))
        return self
    }
}

//
//  Globals.swift
//  Hours
//
//  Created by Keith Irwin on 4/10/20.
//  Copyright © 2020 Zentrope. All rights reserved.
//

import Foundation

public func ViewKitSetup<T>(_ obj: T, _ handle: (T) -> Void) -> T {
    handle(obj)
    return obj
}

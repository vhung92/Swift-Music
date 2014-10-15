//
//  Token.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/15/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation

public struct Token: Hashable {
    let content:Int8
    
    var hashValue: Int {
        return Int(content)
    }
}

public func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.content == rhs.content
}
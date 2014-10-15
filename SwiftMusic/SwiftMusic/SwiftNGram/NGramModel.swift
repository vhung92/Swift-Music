//
//  NGramModel.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/14/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

public class NGramModel {
    private let n: Int
    private var nGrams: [Prefix: [Token:Int]] = [:]
    
    public init(n: Int) {
        self.n = n
    }
    
    public func add(tokens: [Token]) {
        
    }
}

public class Prefix: Hashable {
    let tokens:[Token]
    var length: Int {
        return tokens.count
    }
    
    init(tokens:[Token]) {
        self.tokens = tokens
    }
    
    public var hashValue: Int {
        return reduce(tokens, 0) {$0 + Int($1.content)}
    }
}

public func ==(lhs: Prefix, rhs: Prefix) -> Bool {
    if lhs.length != rhs.length {
        return false
    }
    for (lhitem, rhitem) in Zip2(lhs.tokens, rhs.tokens) {
        if lhitem.content != rhitem.content {
            return false;
        }
    }
    return true
}
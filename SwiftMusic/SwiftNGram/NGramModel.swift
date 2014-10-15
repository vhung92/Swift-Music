//
//  NGramModel.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/14/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Cocoa

public class NGramModel {
    private let n: Int
    private var nGrams: [(Token, Token): [Token:Int]]
    
    public init(n: Int) {
        self.n = n
    }
    
    public add(sequence: TokenSequence) -> Void {
    
    }
}

public class prefix: Hashable {
    let tokenArray:[String]
    
    init(tokenArray:[String]) {
        self.tokenArray = tokenArray
    }
    
    var hashValue: Int {
        return join("", tokenArray).hashValue
    }
}

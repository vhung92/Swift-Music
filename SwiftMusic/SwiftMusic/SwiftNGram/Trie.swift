    //
//  Trie.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/16/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation

    class TrieBranch<T:Hashable> {
    var frequency:Frequency = 0
    var remainingDepth = 0
    private var children: [T:TrieBranch] = [:]
    
    init() {}
    
    init(tokens:[T]) {
        self.add(tokens)
    }
    
    func add(tokens:[T]) {
        remainingDepth = max(remainingDepth, tokens.count)
        self.frequency++
        if tokens.count > 0 {
            let firstToken = tokens[0]
            let tailTokens = Array(suffix(tokens, tokens.count-1))
            if let child = self.children[firstToken] {
                child.add(tailTokens)
            } else {
                let child = TrieBranch(tokens:tailTokens)
                children[firstToken] = child
            }
            
        }
    }
    
    func frequencyOf(nGram:[T]) -> Frequency {
        if nGram.count == 0 {
            return frequency
        } else if let child = children[nGram[0]] {
            let nGramTail = Array(suffix(nGram, nGram.count-1))
            return child.frequencyOf(nGramTail)
        } else {
            return 0
        }
    }
    
    func successorDistribution() -> [(T, Frequency)] {
        return map(children) { (token, branch) in return (token, branch.frequency) }
    }
    
    func successorDistributionOf(prefix:[T]) -> [(T, Frequency)] {
        if prefix.count == 0 {
            return self.successorDistribution()
        } else if let nextNode = children[prefix[0]] {
            let tailPrefix = Array(suffix(prefix, prefix.count - 1))
            return nextNode.successorDistributionOf(tailPrefix)
        } else {
            return []
        }
    }
}
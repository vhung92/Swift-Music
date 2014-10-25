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
    private var children: [T:TrieBranch]?
    
    init() {}
    
    init(tokens:[T]) {
        self.add(tokens)
    }
    
    var remainingDepth:Int {
        if let firstChild = self.children?.values.first {
            return 1 + firstChild.remainingDepth
        } else {
            return 0
        }
    }
    
    var countLeaves:Int {
        if let children = self.children {
            return reduce(children.values, 0) { $0 + $1.countLeaves }
        } else {
            return 1
        }
    }
    
    func countNodesAtDepth(depth:Int) -> Int {
        return countNodesAtDepth(depth, currentDepth: 0)
    }
    
    func countNodesAtDepth(depth:Int, currentDepth:Int) -> Int {
        if depth == currentDepth {
            return 1
        } else if let children = self.children {
            return reduce(children.values, 0) { $0 + $1.countNodesAtDepth(depth, currentDepth: currentDepth+1) }
        } else {
            return 0
        }
    }
    
    func add(var tokens:[T]) {
        self.frequency++
        if tokens.count > 0 {
            let firstToken = tokens.removeAtIndex(0)
            let tailTokens = tokens
            if children == nil {
                children = [:]
            }
            if var child = self.children![firstToken] {
                child.add(tailTokens)
            } else {
                let child = TrieBranch(tokens:tailTokens)
                children![firstToken] = child
            }
        }
    }
    
    func frequencyOf(nGram:[T]) -> Frequency {
        if nGram.count == 0 {
            return frequency
        } else if let child = children?[nGram[0]] {
            let nGramTail = Array(suffix(nGram, nGram.count-1))
            return child.frequencyOf(nGramTail)
        } else {
            return 0
        }
    }
    
    var successorDistribution:[(T, Frequency)] {
        if let children = self.children {
            return map(children) { (token, branch) in return (token, branch.frequency) }
        } else {
            return []
        }
    }
    
    func successorDistributionOf(prefix:[T]) -> [(T, Frequency)] {
        if prefix.count == 0 {
            return self.successorDistribution
        } else if let nextNode = children?[prefix[0]] {
            let tailPrefix = Array(suffix(prefix, prefix.count - 1))
            return nextNode.successorDistributionOf(tailPrefix)
        } else {
            return []
        }
    }
}
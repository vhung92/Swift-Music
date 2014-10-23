//
//  NGramModel.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/14/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

typealias Frequency = UInt64

public class NGramModel {
    
    private let n: Int
    private var nTrie = TrieBranch()
    
    public init(n: Int) {
        self.n = n
    }
    
//    public func train<S>(tokens: LazySequence<MapSequenceView<S, Token>>) {
//        var nGram:[Token] = []
//        
//        for token in tokens {
//            nGram.append(token)
//            
//            while nGram.count > n {
//                nGram.removeAtIndex(0)
//            }
//            
//            if nGram.count == n {
//                addNGram(nGram)
//            }
//        }
//        
//        while nGram.count > 0 {
//            nGram.removeAtIndex(0)
//            addNGram(nGram)
//        }
//    }
    
    public func train(tokens:[Token]) {
        var nGram:[Token] = []
        
        for token in tokens {
            nGram.append(token)
            
            while nGram.count > n {
                nGram.removeAtIndex(0)
            }
            
            if nGram.count == n {
                addNGram(nGram)
            }
        }
        
        while nGram.count > 0 {
            nGram.removeAtIndex(0)
            addNGram(nGram)
        }
    }
    
    private func addNGram(nGram:[Token]) {
        assert(nGram.count <= n, "nGram count was \(nGram.count) (should be \(n)")
        
        nTrie.add(nGram)
    }
    
    public func generate(nTokens: Int, fromStart startSequence:[Token]) -> [Token] {
        var result: [Token] = []
        result.reserveCapacity(nTokens + startSequence.count)
        
        var prefix = startSequence
        for _ in 1...nTokens {
            while prefix.count >= n {
                result.append(prefix.removeAtIndex(0))
            }
            var successorDistribution = nTrie.successorDistributionOf(prefix)
            while successorDistribution.count == 0 {
                if prefix.count == 0 {
                    fatalError("Tried to generate from empty NGramModel")
                }
                // Lower the insight until low enough that the prefix can be found
                result.append(prefix.removeAtIndex(0))
                successorDistribution = nTrie.successorDistributionOf(prefix)
            }
            let generatedToken = tokenFromDistribution(successorDistribution)
            prefix.append(generatedToken)
        }
        result += prefix
        return result
    }
    
    public func generateNextFromPrefix(prefix:[Token]) -> Token {
        let plusOne = prefix.count + 1
        let result = generate(plusOne, fromStart: prefix)[plusOne - 1]
        return result
    }
    
    func tokenFromDistribution(tokenDistribution: [(Token,Frequency)]) -> Token {
        let frequencies:[Double] = map(tokenDistribution) { Double($0.1) }
        let randomIndex = randomIndexFromDistribution(frequencies)
        let token = tokenDistribution[randomIndex].0
        return token
    }
    
    func frequencyOf(gram:[Token]) -> Frequency {
        return nTrie.frequencyOf(gram);
    }
}
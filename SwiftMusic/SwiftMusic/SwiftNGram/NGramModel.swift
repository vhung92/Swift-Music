//
//  NGramModel.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/14/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

public typealias Frequency = UInt64

public class NGramModel<T:Hashable> {
    
    public let n: Int
    private var nTrie = TrieBranch<T>()
    public var filter: ([(T, Frequency)] -> [(T, Frequency)]) = { return $0 }
    
    public init(n: Int) {
        self.n = n
    }
    
    public func countUniqueGramsOfN(n:Int) -> Int {
        assert(n <= self.n && n >= 0)
        return nTrie.countNodesAtDepth(n)
    }
    
    public func train(tokens: SequenceOf<T>) {
        var nGram:[T] = []
        
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
    
    public func train(tokens:[T]) {
        self.train(SequenceOf<T>(tokens))
    }
    
    private func addNGram(nGram:[T]) {
        assert(nGram.count <= n, "nGram count was \(nGram.count) (should be \(n)")
        
        nTrie.add(nGram)
    }
    
    public func generate(nTokens: Int, fromStart startSequence:[T]) -> [T] {
        var result: [T] = []
        result.reserveCapacity(nTokens + startSequence.count)
        
        var prefix = startSequence
        while result.count + prefix.count < nTokens {
            while prefix.count >= n {
                result.append(prefix.removeAtIndex(0))
            }
            var successorDistribution = filter(nTrie.successorDistributionOf(prefix))
            while successorDistribution.count == 0 {
                if prefix.count == 0 {
                    fatalError("Tried to generate from empty NGramModel")
                }
                // Lower the insight until low enough that the prefix can be found
                result.append(prefix.removeAtIndex(0))
                successorDistribution = filter(nTrie.successorDistributionOf(prefix))
            }
            let generatedToken = tokenFromDistribution(successorDistribution)
            prefix.append(generatedToken)
        }
        if prefix.count != n-1 {
            println("!!!!! Generated from shorter prefix: \(prefix.count)")
        }
        result += prefix
        return result
    }
    
    public func generateNextFromPrefix(prefix:SequenceOf<T>) -> T { return generateNextFromPrefix(Array(prefix)) }
    public func generateNextFromPrefix(prefix:[T]) -> T {
        let plusOne = prefix.count + 1
        let result = generate(plusOne, fromStart: prefix)[plusOne - 1]
        return result
    }
    
    func tokenFromDistribution(tokenDistribution: [(T,Frequency)]) -> T {
        let frequencies:[Double] = map(tokenDistribution) { Double($0.1) }
        let randomIndex = randomIndexFromDistribution(frequencies)
        let token = tokenDistribution[randomIndex].0
        return token
    }
    
    func frequencyOf(gram:SequenceOf<T>) -> Frequency { return self.frequencyOf(Array(gram)); }
    func frequencyOf(gram:[T]) -> Frequency {
        return nTrie.frequencyOf(gram);
    }
}